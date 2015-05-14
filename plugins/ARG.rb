require 'cinch'
require 'yaml'
require 'time_diff'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'digest'
require 'json'

ARGCMD			= "http://j.mp/ARGcmd"
SITREP			= "http://j.mp/ONIsitrp"
HYPE_URL		= "http://halo.stckr.co.uk/media/img/hype.png"
POTATO_URL		= "http://halo.stckr.co.uk/media/img/halo5-potato.png"
STATS_URL		= "http://arg.furiousn00b.com/HUNTtheTRUTH/irc/halo5.html"
LOGS_URL		=  "http://halo.stckr.co.uk/"
LOGS_DIR		= "logs/TRUTH/2015/LOGS/"
LOGS_REGEX		= /([0-9]{2}-[0-9]{2}-[0-9]{4})/
TUMBLR_URL		= "http://huntthetruth.tumblr.com"
HALO5_URL		= "http://www.xbox.com/halo5"
RSS_URL			= "http://huntthetruth.tumblr.com/rss"
SIGNAL_URL      = "http://93208466931351102797.com/709782/date.php"
CRICKETS_URL	= "https://www.youtube.com/watch?v=K8E_zMLCRNg"
INCEPTION_URL	= "https://youtu.be/8ZeyG8z86kI"

ACCESS_DENIED   = "Ha! Lower being, you dare summon me? You have no power here"
CHANGE_NICK     = "Please use your Halo Waypoint Username or Gamertag as your nickname in the chat. You can use /nick to change your nickname. Make sure not to use spaces, as they won't work, use dashes (-) or underscores (_) or simply remove the space :)"
REGISTER_NICK     = "Looks like you haven't registered your nickname. It is advisable to register your nickname so you can fully participate in chat. See here for details: http://wiki.mibbit.com/index.php/Create_your_own_nickname :)"
HUNT_THE_SIGNAL_URL = "https://www.huntthesignal.com"

TABLE_FLIP = "(╯°□°）╯︵ ┻━┻"
TABLE_BACK = "┬─┬ノ( º _ ºノ)"

class ARG
	include Cinch::Plugin

	listen_to :connect, method: :identify
	listen_to :connect, method: :load_db
	listen_to :connect, method: :load_rss
	listen_to :join, method: :join_events

	timer 180, method: :timer

	match /signal/i, method: :signal
	match /countdown/i, method: :countdown
	match /halo5/i, method: :halo5
	match /e3/i, method: :e3
	match /ask .+\?$/i, method: :ask
	match /arg(.*)/i, method: :arg
	match /commands/i, method: :commands
	match /nick/i, method: :nick
	match /regnick/i, method: :regnick
	match /sitrep/i, method: :sitrep
	match /stats/i, method: :stats
	match /logs(.*)/i, method: :logs
	match /slap (.+)/i, method: :slap
	match /hype/i, method: :hype
	match /rimshot/i, method: :rimshot
	match /potato/i, method: :potato
	match /crickets/i, method: :crickets
	match /inception/i, method: :inception
	match /flip/i, method: :flip
	match /putback/i, method: :putback
	match /say (#\w+) (.+)/i, method: :say
	match /notice (#\w+) (.+)/i, method: :notice
	match /join (#[[:alnum:]]+)/i, method: :join
	match /part (#[[:alnum:]]+)/i, method: :part
	match /quit(.*)/i, method: :quit
	match /rehash/i, method: :load_db

	def load_db(m)
		@responses = YAML.load_file("#{config[:db]}/ask.yaml")
		@arg = YAML.load_file("#{config[:db]}/arg.yaml")
		@slaps = YAML.load_file("#{config[:db]}/slaps.yaml")
		@dates = YAML.load_file("#{config[:db]}/dates.yaml")
	end

	def signal(m)
		timeDiff = JSON.parse(open(SIGNAL_URL).read)["timeDiff"]
		currentTime = Time.now
		timeRemaining = Time.diff(currentTime, Time.at(currentTime.to_i+timeDiff), "%h:%m:%s")[:diff]
		m.reply "[http://www.huntthesignal.com] Time Remaining: #{timeRemaining}"
	end

	def load_rss(m)
		@doc = Nokogiri::XML(open(RSS_URL))
		@guid = Hash.new
		@guid[1] = @doc.xpath('//guid').first.text
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

	def arg(m,q)
		m.reply q.empty?? @arg["help"].first : @arg[q.strip.downcase].first
	end

	def commands(m)
		m.reply "List of commands - #{ARGCMD}"
	end

	def nick(m)
		m.reply @arg["nick"].first
	end

	def regnick(m)
		m.reply @arg["regnick"].first
	end

	def sitrep(m)
		m.reply "//CLASSIFIED//TRUTH//SITREP - #{SITREP}"
	end

	def stats(m)
		m.reply STATS_URL
	end

	def logs(m,log)
		m.reply log[LOGS_REGEX].nil?? LOGS_URL : "#{LOGS_URL}#{LOGS_DIR}#{log.strip}.log"
	end

	def slap(m,nick)
		m.action_reply "slaps #{nick.strip} with #{@slaps[rand(0..@slaps.length)]}"
	end

	def hype(m)
		m.reply "#{HYPE_URL}"
	end

	def rimshot(m)
		m.action_reply "BA DOOM *TSH*"
	end

	def potato(m)
		m.reply "Hi, how are you holding up? Because I'm a potato - #{POTATO_URL}"
	end

	def crickets(m)
		m.reply CRICKETS_URL
	end

	def inception(m)
		m.reply INCEPTION_URL
	end

	def flip(m)
		m.reply TABLE_FLIP
	end

	def putback(m)
		m.reply TABLE_BACK
	end

	def timer
		doc = Nokogiri::XML(open(RSS_URL))
		guid = doc.xpath('//guid').first.text
		title = doc.xpath('//title')[1].text

		if(doc.xpath('//guid').first.text != @guid[1])
			Channel("#halo5").notice "New HUNTtheTRUTH blog post: #{title} #{guid}"
			@guid[1] = doc.xpath('//guid').first.text
		end

	end

	def join_events(m)
		notify_mib(m)
	end

	def notify_mib(m)
		if m.user.nick.match(/^mib_/) then User(m.user.nick).notice(CHANGE_NICK) end
		if !m.user.authed? then User(m.user.nick).notice(REGISTER_NICK) end
	end

	def say(m,channel,msg)
		User(m.user.nick).admin?? Channel(channel).send(msg.strip) : m.reply(ACCESS_DENIED)
	end

	def notice(m,channel,msg)
		User(m.user.nick).admin?? Channel(channel).notice(msg.strip) : m.reply(ACCESS_DENIED)
	end

	def join(m,channel)
		User(m.user.nick).admin?? Channel(channel).join : m.reply(ACCESS_DENIED)
	end

	def part(m,channel)
		User(m.user.nick).admin?? Channel(channel).part : m.reply(ACCESS_DENIED)
	end

	def quit(m,msg)
		if User(m.user.nick).owner?
			bot.plugins.each { |plugin|
				plugin.respond_to?(:write) ? plugin.write : nil
			}
			bot.info("Received valid quit command from #{m.user.name}")
			bot.quit(msg.strip.empty?? "And I shall taketh my leave, for #{m.user.name} doth command it!" : msg.strip)
		else
			bot.warn("Unauthorized quit command from #{m.user.nick}")
			m.reply("I'm afraid I can't let you do that", true)
		end
	end

	def identify(m)
		bot.irc.send("ns identify #{config[:password]}")
	end

end