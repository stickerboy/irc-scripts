class Logger
	include Cinch::Plugin

	listen_to :connect, method: :setup
	listen_to :disconnect, method: :cleanup
	listen_to :channel, method: :log_public_message
	listen_to :join, method: :log_join
	listen_to :part, method: :log_part
	listen_to :nick, method: :log_nick
	listen_to :ban, method: :log_ban
	timer 60, method: :check_midnight

	def initialize(*args)
		super
		@short_format		= "%m-%d-%Y"
		@long_format		= "%m-%d-%Y %H:%M:%S"
		@time_format		= "%H:%M:%S"
		@filename			= "logs/log-#{Time.now.strftime(@short_format)}.log"
		@logfile			= File.open(@filename,"w")
		@midnight_message	= "=== The dawn of a new day: #{@short_format} ==="
		@last_time_check	= Time.now
	end

	def setup(*)
		bot.debug("Opened message logfile at #{@filename}")
	end

	def cleanup(*)
		@logfile.close
		bot.debug("Closed message logfile at #{@filename}.")
	end

	### Called every X seconds to see if we need to rotate the log
	def check_midnight
		time = Time.now
		if time.day != @last_time_check.day
			@filename = "log-#{Time.now.strftime(@short_format)}.log"
			@logfile = File.open(@filename,"a")
			@logfile.puts(time.strftime(@midnight_message))
		end
		@last_time_check = time
	end

	### Logs a message!
	def log_public_message(m)
		time = Time.now.strftime(@time_format)
		@logfile.puts(sprintf( "[%{time}] <%{nick}> %{msg}",
								:time	=> time,
								:nick	=> m.user.name,
								:msg	=> m.message))
	end

	### Logs a message!
	def log_ban(m,banmask)
		time = Time.now.strftime(@time_format)
		@logfile.puts(sprintf( "[%{time}] #{m.user.name} banned %{nick} from the channel (%{mask})",
								:time	=> time,
								:nick	=> banmask.to_s,
								:mask	=> banmask))
	end

	### Logs join
	def log_join(m)
		time = Time.now.strftime(@time_format)
		@logfile.puts(sprintf( "[%{time}] %{nick} joined the channel [%{host}]",
								:time	=> time,
								:host	=> User(m.user.nick).host,
								:nick	=> m.user.name))
	end

	### Logs part
	def log_part(m)
		time = Time.now.strftime(@time_format)
		@logfile.puts(sprintf( "[%{time}] %{nick} left the channel [%{host}]",
								:time	=> time,
								:host	=> User(m.user.nick).host,
								:nick	=> m.user.name))
	end

	### Logs kick
	def log_kick(m)
		time = Time.now.strftime(@time_format)
	end

end