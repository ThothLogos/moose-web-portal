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
    db_password:    @config[10],
    smtp_server:    @config[11],
    smtp_port:      @config[12],
    smtp_account:   @config[13],
    smtp_password:  @config[14]

# Specify name of folder for CSS, JavaScript, Images
set public_folder:  'assets'

# Load user database
db = UserData.new(settings.db_name, settings.db_user, settings.db_password)

# Site top level
get '/' do
  erb :home
end

# Contact page
get '/contact/?' do
  erb :contact
end

# Register page for new accounts
get '/register/?' do
  erb :register
end

# Request to create new account
post '/register/?' do
  username = params[:username]
  email = params[:email]
  password = params[:password]
  confirm = params[:confirm]

  dupe = db.username_exist?(username) || db.email_exist?(email) ? true : false

  if !dupe && password == confirm
    
    db.send_mail_verification(email, settings.smtp_server, settings.smtp_port,
                              settings.smtp_account, settings.smtp_password)

    #db.add_user(username, email, password, "saltsaltsalt")
    erb :success, locals: { username:  username,
                            email:     email,
                            password:  password }
  else
    # flash error
    erb :home # temp
  end
end

# Password recovery page
get '/recovery/?' do
  erb :recovery
end

post '/recovery/?' do
  email = params[:email]
  if db.email_exist?(email)
    # send recovery mail
    erb :success, locals: { email:  email }
  else
    # flash failure
    erb :home # temp
  end
end

# 404
not_found do
  erb :not_found
end