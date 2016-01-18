# -*- coding: utf-8 -*-
#
# = Cinch advanced message logging plugin
# Fully-featured logging module for cinch with both
# plaintext and HTML logs.
#
# == Configuration
# Add the following to your bot’s configure.do stanza:
#
#   config.plugins.options[Cinch::LogPlus] = {
#     :plainlogdir => "/tmp/logs", # required
#     :timelogformat => "%H:%M",
#     :extrahead => ""
#   }
#
# [plainlogdir]
#   This required option specifies where the plaintext logfiles
#   are kept.
# [timelogformat ("%H:%M")]
#   Timestamp format for the messages. The usual date(1) format
#   string.
# [extrahead ("much css")]
#   Extra snippet of HTML to include in the HTML header of
#   each file. The default is a snippet of CSS to nicely
#   format the log table, but you can overwrite this completely
#   by specifying this option. It could also include Javascript
#   if you wanted. See Cinch::LogPlus::DEFAULT_CSS for the default
#   value of this option.
#
# == Author
# Marvin Gülker (Quintus)
#
# == License
# An advanced logging plugin for Cinch.
# Copyright © 2014,2015 Marvin Gülker
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "cgi"
require "time"
require_relative "mirc_codes_converter"

class LogPlus
  include Cinch::Plugin

  # Hackish mini class for catching Cinch’s outgoing messages, which
  # are not covered by the :channel event. It’d be impossible to log
  # what the bot says otherwise, and compared to monkeypatching Cinch
  # this is still the cleaner approach.
  class OutgoingLogger < Cinch::Logger

	# Creates a new instance. The block passed to this method will
	# be called for each outgoing message. It will receive the
	# outgoing message (string), the level (symbol), and whether it’s
	# a NOTICE (true) or PRIVMSG (false) as arguments.
	def initialize(&callback)
	  super(File.open("/dev/null"))
	  @callback = callback
	end

	# Logs a message. Calls the callback if the +event+ is
	# an "outgoing" event.
	def log(messages, event = :debug, level = event)
	  if event == :outgoing
		Array(messages).each do |msg|
		  if msg =~ /^PRIVMSG .*?:/
			@callback.call($', level, false)
		  elsif msg =~ /^NOTICE .*?:/
			@callback.call($', level, true)
		  end
		end
	  end
	end

  end

  set :required_options, [:plainlogdir]

  match /log stop/, :method => :cmd_log_stop
  match /log start/, :method => :cmd_log_start

  listen_to :connect,    :method => :startup
  listen_to :channel,    :method => :log_public_message
  listen_to :topic,      :method => :log_topic
  listen_to :join,       :method => :log_join
  listen_to :leaving,    :method => :log_leaving
  listen_to :nick,       :method => :log_nick
  listen_to :mode_change,:method => :log_modechange
  timer 60,              :method => :check_midnight

  # Called on connect, sets up everything.
  def startup(*)
	@plainlogdir = config[:plainlogdir]
	@timelogformat = config[:timelogformat] = "%H:%M:%S"
	@extrahead = config[:extrahead]
	@stopped = false

	@last_time_check = Time.now
	@plainlogfile    = nil

	@filemutex = Mutex.new

	# Add our hackish logger for catching outgonig messages.
	bot.loggers.push(OutgoingLogger.new(&method(:log_own_message)))

	reopen_logs

	# Disconnect event is not always issued, so we just use
	# Ruby’s own at_exit hook for cleanup.
	at_exit do
	  @filemutex.synchronize do
		@plainlogfile.close
	  end
	end
  end

  # Timer target. Creates new logfiles if midnight has been crossed.
  def check_midnight
	time = Time.now

	# If day changed, finish this day’s logfiles and start new ones.
	reopen_logs unless @last_time_check.day == time.day

	@last_time_check = time
  end

  def cmd_log_stop(msg)
	if @stopped
		msg.reply "Logs are not currently being tracked"
	  return
	end

	unless msg.channel.opped?(msg.user)
	  msg.reply ACCESS_DENIED
	  return
	end

	msg.reply "I see. I will close down my ears so everything that follows remains private."
	@stopped = true
  end

  def cmd_log_start(msg)
	unless @stopped
	  msg.reply "I am logging the conversation already."
	  return
	end

	unless msg.channel.opped?(msg.user)
	  msg.reply ACCESS_DENIED
	  return
	end

	msg.reply "Firing up them 'ol logs again"
	@stopped = false
  end

  # Target for all public channel messages/actions not issued by the bot.
  def log_public_message(msg)
	return if @stopped

	@filemutex.synchronize do
	  if msg.action?
		log_plaintext_action(msg)
	  else
		log_plaintext_message(msg)
	  end
	end
  end

  # Target for all messages issued by the bot.
  def log_own_message(text, level, is_notice)
	return if @stopped

	@filemutex.synchronize do
	  log_own_plainmessage(text, is_notice)
	end
  end

  # Target for /topic commands.
  def log_topic(msg)
	return if @stopped

	@filemutex.synchronize do
	  log_plaintext_topic(msg)
	end
  end

  def log_nick(msg)
	return if @stopped

	@filemutex.synchronize do
	  log_plaintext_nick(msg)
	end
  end

  def log_join(msg)
	return if @stopped

	@filemutex.synchronize do
	  log_plaintext_join(msg)
	end
  end

  def log_leaving(msg, leaving_user)
	return if @stopped

	@filemutex.synchronize do
	  log_plaintext_leaving(msg, leaving_user)
	end
  end

  def log_modechange(msg, ary)
	return if @stopped

	@filemutex.synchronize do
	  log_plaintext_modechange(msg, ary)
	end
  end

  private

  # Helper method for generating the file basename for the logfiles
  # and appending the given extension (which must include the dot).
  def genfilename(ext)
	Time.now.strftime("%Y-%m-%d") + ext
  end

  # Helper method for determining the status of the user sending
  # the message. Returns one of the following strings:
  # "opped", "halfopped", "voiced", "".
  def determine_status(msg, user = msg.user)
	return "" unless msg.channel # This is nil for leaving users
	return "" unless user # server-side NOTICEs

	user = user.name if user.kind_of?(Cinch::User)

	if user == bot.nick
	  " * "
	elsif msg.channel.owner?(user)
	  "&"
	elsif msg.channel.opped?(user)
	  "@"
	elsif msg.channel.half_opped?(user)
	  "%"
	elsif msg.channel.voiced?(user)
	  "+"
	else
	  ""
	end
  end

  # Finish a day’s logfiles and open new ones.
  def reopen_logs
	@filemutex.synchronize do

	  #### plain log file ####
	  # This one is easier, we can just open plaintext files in append mode
	  # (they have no preamble and postamble)

	  # Close plain file if existing (startup!)
	  @plainlogfile.close if @plainlogfile
	  @plainlogfile = File.open(File.join(@plainlogdir, genfilename(".log")), "a")
	  @plainlogfile.sync = true

	  # Log topic after midnight rotation.
	  unless bot.channels.empty?
		@plainlogfile.puts(sprintf("%{time} %{nick} | %{msg}",
								   :time => Time.now.strftime(@timelogformat),
								   :nick => "(system message)",
								   :msg => "The topic for this channel is currently “#{bot.channels.first.topic}”."))
	  end
	end

	bot.info("Opened new logfiles.")
  end

  # Logs the given message to the plaintext logfile.
  # Does NOT acquire the file mutex!
  def log_plaintext_message(msg)
	@plainlogfile.puts(sprintf("%{time} #{determine_status(msg)}%{nick} | %{msg}",
							   :time => msg.time.strftime(@timelogformat),
							   :nick => msg.user.to_s,
							   :msg => msg.message))
  end

  # Logs the given text to the plaintext logfile. Does NOT
  # acquire the file mutex!
  def log_own_plainmessage(text, is_notice)
	@plainlogfile.puts(sprintf("[%{time}] %{nick} | %{msg}",
							   :time => Time.now.strftime(@timelogformat),
							   :nick => bot.nick,
							   :msg => text))
  end

  # Logs the given action to the plaintext logfile. Does NOT
  # acquire the file mutex!
  def log_plaintext_action(msg)
	@plainlogfile.puts(sprintf("%{time} **%{nick} %{msg}",
							   :time => msg.time.strftime(@timelogformat),
							   :nick => msg.user.name,
							   :msg => msg.action_message))
  end

  # Logs the given topic change to the HTML logfile. Does NOT
  # acquire the file mutex!
  def log_plaintext_topic(msg)
	@plainlogfile.puts(sprintf("%{time} *%{nick} changed the topic to “%{msg}”.",
					   :time => msg.time.strftime(@timelogformat),
					   :nick => msg.user.name,
					   :msg => msg.message))
  end

  def log_plaintext_nick(msg)
	oldnick = msg.raw.match(/^:(.*?)!/)[1]
	@plainlogfile.puts(sprintf("%{time} --%{oldnick} is now known as %{newnick}",
							   :time => msg.time.strftime(@timelogformat),
							   :oldnick => oldnick,
							   :newnick => msg.message))
  end

  def log_plaintext_join(msg)
	@plainlogfile.puts(sprintf("%{time} --> %{nick} entered %{channel}.",
							   :time => msg.time.strftime(@timelogformat),
							   :nick => msg.user.name,
							   :channel => msg.channel.name))
  end

  def log_plaintext_leaving(msg, leaving_user)
	if msg.channel?
	  text = "%{nick} left #{msg.channel.name} (%{msg})"
	else
	  text = "%{nick} left the IRC network (%{msg})"
	end

	@plainlogfile.puts(sprintf("%{time} <--#{text}",
							   :time => msg.time.strftime(@timelogformat),
							   :nick => leaving_user.name,
							   :msg => msg.message))
  end

  def log_plaintext_modechange(msg, changes)
	adds = changes.select{|subary| subary[0] == :add}
	removes = changes.select{|subary| subary[0] == :remove}

	change = ""
	unless removes.empty?
	  change += removes.reduce("-"){|str, subary| str + subary[1] + (subary[2] ? " " + subary[2] : "")}.rstrip
	end
	unless adds.empty?
	  change += adds.reduce("+"){|str, subary| str + subary[1] + (subary[2] ? " " + subary[2] : "")}.rstrip
	end

	@plainlogfile.puts(sprintf("%{time} mode %{change} by %{nick}",
							   :time => msg.time.strftime(@timelogformat),
							   :nick => msg.user.name,
							   :change => change))
  end

  def timestamp_anchor(time)
	"msg-#{time.iso8601}"
  end

end
