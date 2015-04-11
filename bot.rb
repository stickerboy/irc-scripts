require 'cinch'
require 'yaml'
require_relative 'plugins/ARG.rb'

config = YAML.load_file("config.yaml")

p config[:channels]

bot = Cinch::Bot.new do
  configure do |c|
	c.nick = config[:nick]
	c.realname = config[:realname]
	c.user = "pi"
	c.server = config[:server]
	c.channels = config[:channels]
	c.plugins.plugins = [ARG]
	c.plugins.options[ARG] = {
		:password => config[:password],
		:db => config[:db],
		:quitnick => config[:quitnick]
   }
  end
end

bot.start