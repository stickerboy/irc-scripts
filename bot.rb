require 'cinch'
require_relative 'plugins/ARG.rb'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "stckr|pi1080p"
    c.realname = "stckr|pi1080p"
    c.user = "pi"
    c.server = "irc.uk.mibbit.net"
    c.channels = ["#ilb"]
    c.plugins.plugins = [ARG]
  end
end

bot.start