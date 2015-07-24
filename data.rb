require 'pg'
require 'date'

class UserData

  def initialize(db_name, db_user, db_password)
    @conn = PGconn.connect(:host => "localhost", 
                           :port => 5432,
                           :dbname => db_name,
                           :user => db_user,
                           :password => db_password)
    res = @conn.exec("SELECT * FROM users")
    fields = res.fields

    res.each do |row|
      puts row["id"] + " " + row["username"] + " " + row["email"]
    end
  end

  def user_exist?

  end

  def add_user(username, email, password, salt)
    @conn.exec("INSERT INTO users(username, email, password, salt, created)
                VALUES ('#{username}', 
                        '#{email}',
                        '#{password}',
                        '#{salt}',
                        '#{DateTime.now}')   ")
  end

end