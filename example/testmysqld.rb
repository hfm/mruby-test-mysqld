mysqld = TestMysqld.new
db = MySQL::Database.new mysqld.host, mysqld.username, mysqld.password, mysqld.database, mysqld.port, mysqld.socket

db.execute_batch 'create table sample(id int primary key, text text, f float)'

db.transaction
('a'..'z').to_a.each_with_index do |x,i|
  db.execute_batch('insert into sample(id, text) values(?, ?)', i, x)
end
db.commit

db.execute('select * from sample') {|r, f| puts r}

db.close
mysqld.stop
