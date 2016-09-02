# mruby-test-mysqld   [![Build Status](https://travis-ci.org/hfm/mruby-test-mysqld.svg?branch=master)](https://travis-ci.org/hfm/mruby-test-mysqld)

Setting up a mysqld instance in tmpdir, and destroying it when a mruby program exits. The aim for this project is a port of [Test::mysqld](http://search.cpan.org/~kazuho/Test-mysqld/) to [mruby](https://github.com/mruby/mruby).

## install by mrbgems

- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'hfm/mruby-test-mysqld'
end
```

## example

```ruby
mysqld = TestMysqld.new
# ... Initialize mysqld ...
# ... Starting mysqld ...
# => #<TestMysqld:0x7fcec1821480 @pid=28004, @mysql_install_db="/usr/local/bin/mysql_install_db", @mycnf={:socket=>"/tmp/mruby_testmysqld_1472791284/tmp/mysql.sock", :datadir=>"/tmp/mruby_testmysqld_1472791284/var", :pid_file=>"/tmp/mruby_testmysqld_1472791284/tmp/mysqld.pid"}, @base_dir="/tmp/mruby_testmysqld_1472791284", @mysqld="/usr/local/bin/mysqld">

db = MySQL::Database.new 'localhost', 'root', '', 'test', 3306, mysqld.socket
# => #<MySQL::Database:0x7ff03481e1d0 context=#<Object:0x7ff03481e1a0>>
# ... Execute db query...

db.close
# => nil

mysqld.stop
# ... Shutting down mysqld ...
# => nil
```

## License

under the MIT License:
- see [LICENSE](./LICENSE) file
