require 'cinch'
require 'yaml'
require 'time_diff'

DB_FOLDER		= "plugins/db"
SITREP			= "http://j.mp/ONIsitrp"
POTATO_URL		= "http://halo.stckr.co.uk/media/img/halo5-potato.png"
STATS_URL		= "http://arg.furiousn00b.com/HUNTtheTRUTH/irc/halo5.html"
LOGS_URL		=  "http://halo.stckr.co.uk/"
LOGS_DIR		= "logs/TRUTH/2015/LOGS/"
LOGS_REGEX		= /([0-9]{2}-[0-9]{2}-[0-9]{4})/
TUMBLR_URL		= "http://huntthetruth.tumblr.com"
HALO5_URL		= "http://www.xbox.com/halo5"

class ARG
	include Cinch::Plugin

	hook :pre, method: :load_db

	match /ask .+\?$/i, method: :ask
	match /sitrep/i, method: :sitrep
	match /potato/i, method: :potato
	match /arg .+/i, method: :arg
	match /rimshot/i, method: :rimshot
	match /slap (.+)/i, method: :slap
	match /stats/i, method: :stats
	match /logs (.+)/i, method: :logs
	match /countdown/i, method: :countdown
	match /halo5/i, method: :halo5
	match /e3/i, method: :e3

	def load_db(m)
		#Probably want to figure out a way of loading this just once.
		@responses = YAML.load_file("#{DB_FOLDER}/ask.yaml")
		@arg = YAML.load_file("#{DB_FOLDER}/arg.yaml")
		@slaps = YAML.load_file("#{DB_FOLDER}/slaps.yaml")
		@dates = YAML.load_file("#{DB_FOLDER}/dates.yaml")
	end

	def countdown(m)
		audiolog = Time.diff(Time.now, @dates["podcast"], '%d %h Hours %m Minutes')
		m.reply "#HUNTtheTRUTH - Next audio log release: #{audiolog[:diff]} - #{TUMBLR_URL}"
	end

	def halo5(m)
		halo5release = Time.diff(Time.now, @dates["halo5"], '%d %h Hours %m Minutes')
		m.reply "#halo5 - Release Date 27th Oct 2015: #{halo5release[:diff]} - #{HALO5_URL}"
	end

	def e3(m)
		e3launch = Time.diff(Time.now, @dates["e3"], '%d %h Hours %m Minutes')
		m.reply "Countdown to E3 2015 - June 16th to 18th: #{e3launch[:diff]}"
	end

	def ask(m)
		m.reply "#{@responses[rand(0..@responses.length)]}"
	end

	def sitrep(m)
		m.reply "//CLASSIFIED//TRUTH//SITREP - #{SITREP}"
	end

	def potato(m)
		m.reply "Hi, how are you holding up? Because I'm a potato - #{POTATO_URL}"
	end

	def arg(m)
		reply = @arg[m.message.downcase!.split(" ")[1]]
		m.reply reply.nil? ? @arg["help"].first : reply.first
	end

	def rimshot(m)
		m.action_reply "BA DOOM *TSH*"
	end

	def slap(m,nick)
		m.action_reply "slaps #{nick} with #{@slaps[rand(0..@slaps.length)]}"
	end

	def stats(m)
		m.reply STATS_URL
	end

	def logs(m,log)
		m.reply log[LOGS_REGEX].nil? ? LOGS_URL : LOGS_URL  + LOGS_DIR + log + ".log"
	end

end