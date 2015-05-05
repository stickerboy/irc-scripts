require 'cinch'
require 'yaml'
require 'time_diff'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'digest'
require 'json'

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

ACCESS_DENIED   = "Ha! Lower being, you dare summon me? You have no power here"
CHANGE_NICK     = "Please use your Halo Waypoint Username or Gamertag as your nickname in the chat. You can use /nick to change your nickname. Make sure not to use spaces, as they won't work, use dashes (-) or underscores (_) or simply remove the space :)"
HUNT_THE_SIGNAL_URL = "https://www.huntthesignal.com"

class ARG
	include Cinch::Plugin

	listen_to :connect, method: :identify
	listen_to :connect, method: :load_db
	listen_to :connect, method: :load_rss
	listen_to :connect, method: :load_whois
	listen_to :join, method: :join_events
	timer 180, method: :timer
	timer 600, method: :hts_changes
	timer 600, method: :write_changes

	match /ask .+\?$/i, method: :ask
	match /sitrep/i, method: :sitrep
	match /hype/i, method: :hype
	match /signal/i, method: :signal
	match /potato/i, method: :potato
	match /arg(.*)/i, method: :arg
	match /rimshot/i, method: :rimshot
	match /slap (.+)/i, method: :slap
	match /stats/i, method: :stats
	match /logs(.*)/i, method: :logs
	match /countdown/i, method: :countdown
	match /halo5/i, method: :halo5
	match /e3/i, method: :e3
	match /say (#\w+) (.+)/i, method: :say
	match /join (#[[:alnum:]]+)/i, method: :join
	match /part (#[[:alnum:]]+)/i, method: :part
	match /quit(.*)/i, method: :quit
	match /rehash/i, method: :load_db
	match /crickets/i, method: :crickets
	match /whois ([[:print:]]+)/i, method: :whois

	def load_db(m)
		@responses = YAML.load_file("#{config[:db]}/ask.yaml")
		@arg = YAML.load_file("#{config[:db]}/arg.yaml")
		@slaps = YAML.load_file("#{config[:db]}/slaps.yaml")
		@dates = YAML.load_file("#{config[:db]}/dates.yaml")

		@htsSum = page_sum(HUNT_THE_SIGNAL_URL)
	end

	def load_whois(m)
		@whois = Hash.new { |k,v| k[v] = Array.new }
		if File.exists?("#{config[:db]}/whois.yaml") then
			#We want to do this to preserve the fact that empty results still return an empty array rather than nil.
			@whois.update(YAML.load_file("#{config[:db]}/whois.yaml"))
		end
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

	def hype(m)
		m.reply "#{HYPE_URL}"
	end

	def signal(m)
		timeDiff = JSON.parse(open(SIGNAL_URL).read)["timeDiff"]
		currentTime = Time.now
		timeRemaining = Time.diff(currentTime, Time.at(currentTime.to_i+timeDiff), "%h:%m:%s")[:diff]
		m.reply "[http://www.huntthesignal.com] Time Remaining: #{timeRemaining}"
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

	def hts_changes
		currentSum = page_sum(HUNT_THE_SIGNAL_URL)
		bot.info "Expected MD5: #{@htsSum}"
		bot.info "Current MD5: #{currentSum}"
		if @htsSum != currentSum
			Channel('#Halo5').notice "http://huntthesignal.com has changed!"
			@htsSum = currentSum
		end
	end

	#Flush new data to the drive every five minutes.
	def write_changes
		bot.info("Writing recent changes...")
		IO.binwrite("#{config[:db]}/whois.yaml",@whois.to_yaml)
		#Probably should actually add some error handling/backup type stuff.
		bot.info("Write complete.")
	end

	def join_events(m)
		notify_mib(m)
		update_whois(m)
	end

	def notify_mib(m)
		if m.user.nick.match(/^mib_/) then User(m.user.nick).notice(CHANGE_NICK) end
	end

	def update_whois(m)
		result = @whois[User(m.user.nick).host]
		result << m.user.nick
		result.uniq!
	end

	def say(m,channel,msg)
		User(m.user.nick).admin?? Channel(channel).send(msg.strip) : m.reply(ACCESS_DENIED)
	end

	def join(m,channel)
		User(m.user.nick).admin?? Channel(channel).join : m.reply(ACCESS_DENIED)
	end

	def part(m,channel)
		User(m.user.nick).admin?? Channel(channel).part : m.reply(ACCESS_DENIED)
	end

	def quit(m,msg)
		if User(m.user.nick).owner?
			bot.info("Received valid quit command from #{m.user.name}")
			write_changes
			bot.quit(msg.strip.empty?? "And I shall taketh my leave, for #{m.user.name} doth command it!" : msg.strip)
		else
			bot.warn("Unauthorized quit command from #{m.user.nick}")
			m.reply("I'm afraid I can't let you do that", true)
		end
	end

	def identify(m)
		bot.irc.send("ns identify #{config[:password]}")
	end

	def page_sum(page)
		response = Net::HTTP.get_response(URI(page))
		data = open(response['location']).read
		Digest::MD5.hexdigest(data)
	end

	def crickets(m)
		m.reply CRICKETS_URL
	end

	def whois(m,nick)
		if User(m.user.nick).admin?
			hostmask = User(nick).host
			search = hostmask.nil?? nick : hostmask
			results = @whois.has_key?(search) ? @whois[search] : nil
			m.reply results.nil?? "No known matches." : "Known aliases: #{results.join(", ")}"
		else
			m.reply ACCESS_DENIED
		end
	end

end