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
                        '#{generate_random_code}' ) ")
  end

  # Random 16-character code to serve as email verification/password reset
  def generate_random_code
    return SecureRandom.hex(8)
  end

  # Returns the verification code stored in the database for a given email
  def verification_code(email)
    res = @conn.exec("SELECT verifycode FROM users WHERE email='#{email}'")
    return res.getvalue(0,0)
  end

  # Checks to see if the provided verification code exists in the database
  def verification_exist?(code)
    res = @conn.exec("SELECT verifycode FROM users WHERE verifycode='#{code}'")
    return res.field_values("verifycode").empty? ? false : true
  end

  # Packages and sends email verification via SMTP
  def send_mail_verification(email, server, port, username, password)
    subject = "Account Verification"
    body = ["Thank you for registering. You will need to verify this email ",
            "before your account is active.\n\n\n",
            "Verification Code: #{verification_code(email)}"]
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
      body:                 body.join )
  end

  # Change account verified flag to true based on verification code
  def verify_account(code)
    res = @conn.exec("SELECT id FROM users WHERE verifycode='#{code}'")
    @conn.exec("UPDATE users SET verified='t' WHERE id='#{res.getvalue(0,0)}'")
  end

  # Inserts a new random code into the database to be used for password reset
  def set_reset_code(email)
    @conn.exec("UPDATE users SET resetcode='#{generate_random_code}'
                WHERE email='#{email}'")
  end

  # Returns the stored reset code for a provided email
  def reset_code(email)
    res = @conn.exec("SELECT resetcode FROM users WHERE email='#{email}'")
    return res.getvalue(0,0)
  end

  # Checks to see if a provided password reset code exists in the database
  def reset_exist?(code)
    res = @conn.exec("SELECT resetcode FROM users WHERE resetcode='#{code}'")
    return res.field_values("resetcode").empty? ? false : true
  end

  # Packages and sends password recovery request email via SMTP
  def send_mail_recovery(email, server, port, username, password)
    subject = "Password Reset Request"
    body = ["A password reset request has been initiated for this account. ",
            "If you did not initiate this request, please ignore this message. ",
            "\n\n\nAccount Recovery Code: #{reset_code(email)}"]
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
      body:                 body.join )
  end

end