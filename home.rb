require 'sinatra'
require 'pg'
require './data.rb'
require 'sinatra/reloader' if development?

# Parses configuration options from 'config' file in site's root directory
def read_config

  config_args = [] # Array to hold the options

  # Read each line, ignoring any lines containing the "#" character or
  # lines that contain only whitespace or are blank.
  File.open("config", "r") do |file|
    file.each_line do |line|
      line.chomp!
      config_args << line unless line.include?('#') || line.empty?
    end
  end

  return config_args
end

# Prepare array of configuration options
@config = read_config

# Move configuration options from array to Sinatra's global settings
set title:          @config[0], 
    server_long:    @config[1], 
    server_short:   @config[2],
    admin_mail:     @config[3],
    webmaster_mail: @config[4],
    main_logo:      @config[5],
    second_logo:    @config[6],
    footer_caption: @config[7],
    db_name:        @config[8],
    db_user:        @config[9],
    db_password:    @config[10]

# Specify name of folder for CSS, JavaScript, Images
set public_folder:  'assets'

# Load user database
db = UserData.new(settings.db_name, settings.db_user, settings.db_password)

# Site top level
get '/' do
  erb :home
end

# Contact page
get '/contact' do
  erb :contact
end

# Register page for new accounts
get '/register' do
  erb :register
end

# Password recovery page
get '/recovery' do
  erb :recovery
end

# 404
not_found do
  erb :not_found
end