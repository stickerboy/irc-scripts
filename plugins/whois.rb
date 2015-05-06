class Whois 
	include Cinch::Plugin

	listen_to :connect, method: :load
	listen_to :join, method: :update

	timer 600, method: :write

	match /whois ([[:print:]]+)/i, method: :whois

	def load(m)
		@whois = Hash.new { |k,v| k[v] = Array.new }
		if File.exists?("#{config[:db]}/whois.yaml") then
			#We want to do this to preserve the fact that empty results still return an empty array rather than nil.
			@whois.update(YAML.load_file("#{config[:db]}/whois.yaml"))
		end
	end

	#Flush new data to the drive every five minutes.
	def write(m=nil)
		bot.info("Writing recent changes...")
		IO.binwrite("#{config[:db]}/whois.yaml",@whois.to_yaml)
		#Probably should actually add some error handling/backup type stuff.
		bot.info("Write complete.")
	end

	def update(m)
		result = @whois[User(m.user.nick).host]
		result << m.user.nick
		result.uniq!
	end

	def whois(m,nick)
		if User(m.user.nick).trusted?
			hostmask = User(nick).host
			search = hostmask.nil?? nick : hostmask
			results = @whois.has_key?(search) ? @whois[search] : nil
			m.reply results.nil?? "No known matches." : "Known aliases: #{results.join(", ")}"
		else
			m.reply ACCESS_DENIED
		end
	end

end