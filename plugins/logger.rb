class Module
	def add_logging(*method_names)
		method_names.each do |method_name|
			original_method = instance_method(method_name)
			define_method(method_name) do |*args,&blk|
				time_format = "%H:%M:%S"
				time = Time.now.strftime(time_format)
				Logger.log "[#{time}] <#{@bot.nick}> #{args.first}"
				original_method.bind(self).call(*args,&blk)
			end
		end
	end
end

class Cinch::Message
	add_logging :reply
end

class Logger
	include Cinch::Plugin

	listen_to :connect, method: :setup
	listen_to :disconnect, method: :cleanup
	listen_to :message, method: :log_public_message
	listen_to :join, method: :log_join
	listen_to :part, method: :log_part
	listen_to :nick, method: :log_nick
	listen_to :kick, method: :log_kick
	listen_to :ban, method: :log_ban
	listen_to :unban, method: :log_unban
	listen_to :op, method: :log_op
	listen_to :halfop, method: :log_halfop
	listen_to :voice, method: :log_unban
	timer 60, method: :check_midnight
	timer 60, method: :log_flush

	def initialize(*args)
		super
		@short_format		= "%m-%d-%Y"
		@long_format		= "%m-%d-%Y %H:%M:%S"
		@time_format		= "%H:%M:%S"
		@filename			= "logs/log-#{Time.now.strftime(@short_format)}.log"
		@@logfile			= File.open(@filename,"a")
		@midnight_message	= "=== The dawn of a new day: #{@short_format} ==="
		@last_time_check	= Time.now
	end

	def self.log(event)
		@@logfile.puts event
	end

	def setup(*)
		bot.debug("Opened message logfile at #{@filename}")
	end

	def cleanup(*)
		@@logfile.close
		bot.debug("Closed message logfile at #{@filename}.")
	end

	### Called every X seconds to see if we need to rotate the log
	def check_midnight
		time = Time.now
		if time.day != @last_time_check.day
			@filename = "log-#{Time.now.strftime(@short_format)}.log"
			@@logfile = File.open(@filename,"a")
			@@logfile.puts(time.strftime(@midnight_message))
		end
		@last_time_check = time
	end

	def log_flush
		@@logfile.flush
	end

	### Logs channel messages
	def log_public_message(m)
		time = Time.now.strftime(@time_format)
		if m.ctcp_command == "ACTION"
			@@logfile.puts(sprintf( "[%{time}] * <%{nick}> %{msg}",
								:time	=> time,
								:nick	=> m.user.nick,
								:msg	=> m.message.sub('ACTION ', '')))
		else
			@@logfile.puts(sprintf( "[%{time}] <%{nick}> %{msg}",
								:time	=> time,
								:nick	=> m.user.nick,
								:msg	=> m.message))
		end
	end

	### Logs channel join
	def log_join(m)
		time = Time.now.strftime(@time_format)
		@@logfile.puts(sprintf( "[%{time}] * %{nick} joined the channel [%{host}]",
								:time	=> time,
								:host	=> User(m.user.nick).host,
								:nick	=> m.user.nick))
	end

	### Logs channel part
	def log_part(m)
		time = Time.now.strftime(@time_format)
		@@logfile.puts(sprintf( "[%{time}] * %{nick} left the channel [%{host}]",
								:time	=> time,
								:host	=> User(m.user.nick).mask,
								:nick	=> m.user.nick))
	end

	### Logs nick change
	def log_nick(m)
		time = Time.now.strftime(@time_format)
		@@logfile.puts(sprintf( "[%{time}] * %{oldnick} changed their nickname to %{nick} [hostmask: %{host}]",
								:time		=> time,
								:host		=> User(m.user.nick).mask,
								:oldnick	=> m.user.last_nick,
								:nick		=> m.user.nick))
	end




	### Logs kicked user
	def log_kick(m,usr)
		time = Time.now.strftime(@time_format)
		@@logfile.puts(sprintf( "[%{time}] * %{nick} [%{mask}] was kicked from the channel the channel by %{op}",
								:time	=> time,
								:op		=> User(m.user.nick),
								:nick	=> usr.nick,
								:mask	=> User(usr.nick).mask))
	end

	### Logs banned user
	def log_ban(m,usr)
		time = Time.now.strftime(@time_format)
		@@logfile.puts(sprintf( "[%{time}] * %{nick} [%{mask}] was banned from the channel by %{op}",
								:time	=> time,
								:op		=> m.user.nick,
								:nick	=> usr.nick,
								:mask	=> User(usr.nick).mask))
	end

	### Logs unbanned user
	def log_unban(m,usr)
		time = Time.now.strftime(@time_format)
		@@logfile.puts(sprintf( "[%{time}] * ban on %{nick} [%{mask}] was removed by %{op}",
								:time	=> time,
								:op		=> m.user.nick,
								:nick	=> usr.nick,
								:mask	=> User(usr.nick).mask))
	end

	### Logs opped user
	def log_op(m,usr)
		time = Time.now.strftime(@time_format)
		@@logfile.puts(sprintf( "[%{time}] * %{nick} was given Operator status - [%{mask}]",
								:time	=> time,
								:nick	=> usr.nick,
								:mask	=> User(usr.nick).mask))
	end

	### Logs half opped user
	def log_halfop(m,usr)
		time = Time.now.strftime(@time_format)
		@@logfile.puts(sprintf( "[%{time}] * %{nick} was given Half-Op status - [%{mask}]",
								:time	=> time,
								:nick	=> usr.nick,
								:mask	=> User(usr.nick).mask))
	end

	### Logs voiced user
	def log_voice(m,usr)
		time = Time.now.strftime(@time_format)
		@@logfile.puts(sprintf( "[%{time}] * %{nick} was given Voice - [%{mask}]",
								:time	=> time,
								:nick	=> usr.nick,
								:mask	=> User(usr.nick).mask))
	end
end