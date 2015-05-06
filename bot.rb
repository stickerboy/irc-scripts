require 'cinch'
require 'yaml'
require_relative 'plugins/ARG.rb'
require_relative 'plugins/whois.rb'
#Unfortunately required to simplify opening SSL URLs with open-uri
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
config = YAML.load_file("config.yaml")

p config[:channels]

#Add the owner to the admins access list automatically.
config[:admins] << config[:owner]

#Export config as a global (for outside classes)
$config = config

#Modify the base user class to give us useful methods.
class Cinch::User
	def admin?
		$config[:admins].include?(self.nick)
	end

	def owner?
		$config[:owner].eql?(self.nick)
	end
end

bot = Cinch::Bot.new do
  configure do |c|
	c.nick = config[:nick]
	c.realname = config[:realname]
	c.user = "pi"
	c.server = config[:server]
	c.channels = config[:channels]
	c.plugins.plugins = [ARG, Whois]
	c.plugins.options[ARG] = {
		:password => config[:password],
		:db => config[:db],
		:owner => config[:owner],
		:admins => config[:admins]
   }
   c.plugins.options[Whois] = { :db => config[:db] }
  end
end

bot.start