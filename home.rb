require 'sinatra'
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
    logo_path:      @config[5]

# Specify name of folder for CSS, JavaScript, Images
set public_folder:  'assets'

# Site top level
get '/' do
  erb :home
end

# Contact page
get '/contact' do
  erb :contact
end
