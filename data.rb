require 'pg'
require 'date'
require 'pony'
require 'securerandom'

class UserData

  def initialize(db_name, db_user, db_password)
    @conn = PGconn.connect(:host => "localhost", 
                           :port => 5432,
                           :dbname => db_name,
                           :user => db_user,
                           :password => db_password)
  end

  # Query user table for already registered username
  def username_exist?(username)
    res = @conn.exec("SELECT username FROM users WHERE username = '#{username}'")
    # If the query is empty the username doesn't exist, return false
    return res.field_values("username").empty? ? false : true
  end

  # Query user table for already registered email
  def email_exist?(email)
    res = @conn.exec("SELECT email FROM users WHERE email='#{email}'")
    # If the query is empty the email doesn't exist, return false
    return res.field_values("email").empty? ? false : true
  end

  # Add new user to users table
  def add_new_user(username, email, password, salt)
    @conn.exec("INSERT INTO users (
                         username,
                         email,
                         password,
                         salt,
                         created,
                         verified,
                         verifycode )
                VALUES ('#{username}', 
                        '#{email}',
                        '#{password}',
                        '#{salt}',
                        '#{DateTime.now}',
                        'f',
                        '#{generate_verification_code}' ) ")
  end

  # Random 12-character code to serve as email verification/account activation
  def generate_verification_code
    return SecureRandom.hex(8)
  end

  # Returns the verification code stored in the database for a given email
  def verification_code(email)
    res = @conn.exec("SELECT verifycode FROM users WHERE email='#{email}'")
    return res.getvalue(0,0)
  end

  def verification_exist?(code)
    res = @conn.exec("SELECT verifycode FROM users WHERE verifycode='#{code}'")
    return res.field_values("verifycode").empty? ? false : true
  end

  # Packages and sends email verification via SMTP
  def send_mail_verification(email, server, port, username, password)
    subject = "Account Verification"
    Pony.mail(
      to:                   email,
      via:                  :smtp,
      via_options:          {
        address:                server,
        port:                   port,
        enable_starttls_auto:   true,
        user_name:              username,
        password:               password,
        authentication:         :plain,
        domain:                 "localhost"
                            },
      subject:              subject,
      body:                 ("Thank you for registering. You'll need to verify this"
                          + " email before your account is active.\n\n\n"
                          + "Verification code: #{verification_code(email)}") )
  end

  # Change account verified flag to true based on verification code
  def verify_account(code)
    res = @conn.exec("SELECT id FROM users WHERE verifycode='#{code}'")
    @conn.exec("UPDATE users SET verified='t' WHERE id='#{res.getvalue(0,0)}'")
  end

end