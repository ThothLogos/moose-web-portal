require 'pg'
require 'sinatra'

class User

  def initialize(db_name, db_user, db_password)
    conn = PGconn.connect(:host => "localhost", 
                          :port => 5432,
                          :dbname => db_name,
                          :user => db_user,
                          :password => db_password)
    
    res = conn.exec("SELECT * FROM users")
    
    fields = res.fields()
    
    fields.each do |elem|
      print "elem=" + elem + "\n"
    end
    
    res.each do |row|
      puts row["id"] + " " + row["username"] + " " + row["email"]
    end
  end

end