# encoding: UTF-8
require 'cinch'
require 'yaml'
require 'time_diff'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'digest'
require 'json'

LOGS_URL		=  "http://halo.stckr.co.uk/"
LOGS_DIR		= "logs/TRUTH/2015/LOGS/"
LOGS_REGEX		= /([0-9]{2}-[0-9]{2}-[0-9]{4})/
TUMBLR_URL		= "http://huntthetruth.tumblr.com"
RSS_URL			= "http://huntthetruth.tumblr.com/rss"


ACCESS_DENIED	= "Ha! Lower being, you dare summon me? You have no power here"
CHANGE_NICK		= "Please use your Halo Waypoint Username or Gamertag as your nickname in the chat. You can use /nick to change your nickname. Make sure not to use spaces, as they won't work, use dashes (-) or underscores (_) or simply remove the space :)"
REGISTER_NICK	= "Looks like you haven't registered your nickname. It is advisable to register your nickname so you can fully participate in chat. See here for details: http://wiki.mibbit.com/index.php/Create_your_own_nickname :)"

class ARG
	include Cinch::Plugin

	listen_to :connect, method: :identify
	listen_to :connect, method: :load_db
	listen_to :connect, method: :load_oneshots
	listen_to :connect, method: :load_rss
	#listen_to :join, method: :join_events

	timer 180, method: :timer

	match /htt/i, method: :timer
	match /countdown/i, method: :countdown
	match /halo7/i, method: :halo7
	match /e3/i, method: :e3
	match /ask .+\?$/i, method: :ask
	match /arg(.*)/i, method: :arg
	match /nick/i, method: :nick
	match /regnick/i, method: :regnick
	match /logs(.*)/i, method: :logs
	match /slap (.+)/i, method: :slap
	match /expletive/i, method: :yoink
	match /rimshot/i, method: :rimshot
	match /say (#\w+) (.+)/i, method: :say
	match /notice (#\w+) (.+)/i, method: :notice
	match /join (#[[:alnum:]]+)/i, method: :join
	match /uptime/i, method: :uptime
	match /part (#[[:alnum:]]+)/i, method: :part
	match /kick\s+(.+)/i, method: :kick_user
	match /quit(.*)/i, method: :quit
	match /rehash/i, method: :load_db

	def load_db(m)
		@responses = YAML.load_file("#{config[:db]}/ask.yaml")
		@arg = YAML.load_file("#{config[:db]}/arg.yaml")
		@slaps = YAML.load_file("#{config[:db]}/slaps.yaml")
		@dates = YAML.load_file("#{config[:db]}/dates.yaml")
		@yoinks = YAML.load_file("#{config[:db]}/yoinks.yaml")
	end

	def load_oneshots(m)
		@oneshots = YAML.load_file("#{config[:db]}/oneshots.yaml")
		#Clear out the @matchers array so we don't double register.
		self.class.instance_variable_set(:@matchers,[])
		self.class.instance_variable_set(:@handlers,[])
		#Dynamically generate command and method pairs.
		@oneshots.each { |key, value|
			self.class.send(:define_method,key.to_sym, ->(m) { m.reply value })
			self.class.send(:match,/#{key}/i, method: key.to_sym)
		}
		#Force the matchers handler update (may have unforseen consequences, hopefully not though)
		self.send(:__register_matchers)
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

	def halo7(m)
		m.channel.kick(m.user, reason = "TOO SOON!")
	end

	def e3(m)
		e3launch = Time.diff(Time.now, @dates["e3"], '%d %h Hours %m Minutes')
		m.reply "Countdown to E3 2016 - June 14 to 16: #{e3launch[:diff]}"
	end

	def ask(m)
		m.reply "#{@responses[rand(0..@responses.length)]}"
	end

	def arg(m,q)
		m.reply q.empty?? @arg["help"].first : @arg[q.strip.downcase].first
	end

	def nick(m)
		m.reply @arg["nick"].first
	end

	def regnick(m)
		m.reply @arg["regnick"].first
	end

	def logs(m,log)
		m.reply log[LOGS_REGEX].nil?? LOGS_URL : "#{LOGS_URL}#{LOGS_DIR}#{log.strip}.log"
	end

	def slap(m,nick)
		if (nick.strip == bot.nick)
			m.action_reply "slaps #{m.user.nick} instead with #{@slaps[rand(0..@slaps.length)]}"
		else
			m.action_reply "slaps #{nick.strip} with #{@slaps[rand(0..@slaps.length)]}"
		end
	end

	def yoink(m)
		m.reply "#{@yoinks[rand(0..@yoinks.length)]}"
	end

	def rimshot(m)
		m.action_reply "BA DOOM *TSH*"
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

	def kick_user(m,nick,reason = "I'm just a bot, don't take it personally")
		if m.channel.has_user?(nick.strip)
			if User(m.user.nick).trusted?
				if (nick.strip == bot.nick)
					m.reply("I might be a bot, but I'm not going to kick myself ¬_¬")
				else
					m.channel.kick(nick.strip,reason)
				end
			else
				m.reply(ACCESS_DENIED)
			end
		else
			m.action_reply "kicks and misses..."
			m.reply "#{nick.strip} must be a wizzard :o"
		end
	end

	def uptime(m)
		uptime = %x( w | head -1 ).split(',')
		days = uptime[0][9..-1].strip!
		mins = uptime[1].split(':')
        mins = "#{mins[0]} Hours #{mins[1]} mins"
		m.reply(days + mins)
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
