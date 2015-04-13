require 'cinch'
require 'yaml'
require 'time_diff'
require 'nokogiri'
require 'open-uri'

SITREP			= "http://j.mp/ONIsitrp"
POTATO_URL		= "http://halo.stckr.co.uk/media/img/halo5-potato.png"
STATS_URL		= "http://arg.furiousn00b.com/HUNTtheTRUTH/irc/halo5.html"
LOGS_URL		=  "http://halo.stckr.co.uk/"
LOGS_DIR		= "logs/TRUTH/2015/LOGS/"
LOGS_REGEX		= /([0-9]{2}-[0-9]{2}-[0-9]{4})/
TUMBLR_URL		= "http://huntthetruth.tumblr.com"
HALO5_URL		= "http://www.xbox.com/halo5"
RSS_URL			= "http://huntthetruth.tumblr.com/rss"

ACCESS_DENIED   = "Ha! Lower being, you dare summon me? You have no power here"

class ARG
	include Cinch::Plugin

	listen_to :connect, method: :identify
	listen_to :connect, method: :load_db
	listen_to :connect, method: :load_rss
	timer 600, method: :timer

	match /ask .+\?$/i, method: :ask
	match /sitrep/i, method: :sitrep
	match /potato/i, method: :potato
	match /arg(.*)/i, method: :arg
	match /rimshot/i, method: :rimshot
	match /slap (.+)/i, method: :slap
	match /stats/i, method: :stats
	match /logs(.*)/i, method: :logs
	match /countdown/i, method: :countdown
	match /halo5/i, method: :halo5
	match /e3/i, method: :e3
	match /join (#[[:alnum:]]+)/i, method: :join
	match /part (#[[:alnum:]]+)/i, method: :part
	match /quit/i, method: :quit
	match /rehash/i, method: :load_db

	def load_db(m)
		#Export config as a global (for outside classes)
		$config = config;
		@responses = YAML.load_file("#{config[:db]}/ask.yaml")
		@arg = YAML.load_file("#{config[:db]}/arg.yaml")
		@slaps = YAML.load_file("#{config[:db]}/slaps.yaml")
		@dates = YAML.load_file("#{config[:db]}/dates.yaml")
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

	def sitrep(m)
		m.reply "//CLASSIFIED//TRUTH//SITREP - #{SITREP}"
	end

	def potato(m)
		m.reply "Hi, how are you holding up? Because I'm a potato - #{POTATO_URL}"
	end

	def arg(m,q)
		m.reply q.empty?? @arg["help"].first : @arg[q.strip.downcase].first
	end

	def rimshot(m)
		m.action_reply "BA DOOM *TSH*"
	end

	def slap(m,nick)
		m.action_reply "slaps #{nick.strip} with #{@slaps[rand(0..@slaps.length)]}"
	end

	def stats(m)
		m.reply STATS_URL
	end

	def logs(m,log)
		m.reply log[LOGS_REGEX].nil?? LOGS_URL : "#{LOGS_URL}#{LOGS_DIR}#{log.strip}.log"
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

	def join(m, channel)
		User(m.user.nick).admin?? Channel(channel).join : m.reply(ACCESS_DENIED)
	end

	def part(m,channel)
		User(m.user.nick).admin?? Channel(channel).part : m.reply(ACCESS_DENIED)
	end

	def quit(m)
		if User(m.user.nick).owner?
			bot.info("Received valid quit command from #{m.user.name}")
			bot.quit("And I shall taketh my leave, for #{m.user.name} doth command it!")
		else
			bot.warn("Unauthorized quit command from #{m.user.nick}")
			m.reply("I'm afraid I can't let you do that", true)
		end
	end

	def identify(m)
		bot.irc.send("ns identify #{config[:password]}")
	end


	#Modify the base user class to give us useful methods.
	class Cinch::User
		def admin?
			$config[:admins].include?(self.nick)
		end

		def owner?
			$config[:owner].eql?(self.nick)
		end
	end

end