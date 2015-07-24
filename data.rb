require 'pg'
require 'date'

class UserData

  def initialize(db_name, db_user, db_password)
    @conn = PGconn.connect(:host => "localhost", 
                           :port => 5432,
                           :dbname => db_name,
                           :user => db_user,
                           :password => db_password)
    
    # ~ Debug ~ #
    res = @conn.exec("SELECT * FROM users")
    fields = res.fields

    res.each do |row|
      puts row["id"] + " " + row["username"] + " " + row["email"] + " " +
           row["password"] + " " + row["salt"] + " " + row["created"]
    end
  end

  # Query user table for already registered username
  def username_exist?(username)
    res = @conn.exec("SELECT username FROM users WHERE username = '#{username}'")
    # If the query is empty the username doesn't exist, return false
    res.field_values("username").empty? ? (return false) : (return true)
  end

  # Query user table for already registered email
  def email_exist?(email)
    res = @conn.exec("SELECT email FROM users WHERE email='#{email}'")
    # If the query is empty the email doesn't exist, return false
    res.field_values("email").empty? ? (return false) : (return true)
  end

  # Add new user to users table
  def add_user(username, email, password, salt)
    @conn.exec("INSERT INTO users(username, email, password, salt, created)
                VALUES ('#{username}', 
                        '#{email}',
                        '#{password}',
                        '#{salt}',
                        '#{DateTime.now}')   ")
  end

end