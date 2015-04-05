require 'cinch'
require 'yaml'

DB_FOLDER = "plugins/db"

class ARG
	include Cinch::Plugin

	hook :pre, method: :load_db

	def load_db(m)
		#Probably want to figure out a way of loading this just once.
		@responses = YAML.load_file("#{DB_FOLDER}/ask.yaml")
	end

	match "ask"
	def execute(m)
		m.reply "#{@responses[rand(0...@responses.length)]}"
	end

end