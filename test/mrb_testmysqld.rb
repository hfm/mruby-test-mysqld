##
## TestMysqld Test
##

assert("TestMysqld#new") do
  opts = { database: 'example' }

  m = TestMysqld.new(opts)
  d = MySQL::Database.new m.host, m.username, m.password, m.database, m.port, m.socket

  d.execute_batch 'create table sample(id int primary key, text text, f float)'

  d.transaction
  d.execute_batch('insert into sample(id, text) values(?, ?)', 1, 'a')
  d.execute_batch('insert into sample(id, text) values(?, ?)', 2, 'b')
  d.execute_batch('insert into sample(id, text) values(?, ?)', 3, 'c')
  d.commit

  d.execute('select * from sample') {|r, f| puts r}

  assert_nil d.close
  assert_nil m.stop
end
