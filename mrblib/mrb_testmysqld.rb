class TestMysqld
  attr_reader :auto_start, :base_dir, :mycnf, :mysql_install_db, :mysqld, :pid
  def initialize(opts = {})
    @base_dir = opts[:base_dir] || "#{Dir.tmpdir}/mruby_testmysqld_#{Time.now.to_i}"

    @mycnf = opts[:my_cnf] || {}
    @mycnf[:socket] ||= "#{base_dir}/tmp/mysql.sock"
    @mycnf[:datadir] ||= "#{base_dir}/var"
    @mycnf[:pid_file] ||= "#{base_dir}/tmp/mysqld.pid"

    @mysql_install_db = opts[:mysql_install_db] || _find_program('mysql_install_db')
    @mysqld = opts[:mysqld] || _find_program('mysqld')
    @pid = nil
    @auto_start = opts[:auto_start] || 2

    if auto_start
      raise "mysqld is already running (#{mycnf[:pidfile]})" if File.exists? mycnf[:pidfile]
      setup if auto_start >= 2
      start
    end
  end

  def host
    mycnf[:host] || 'localhost'
  end

  def port
    mycnf[:port] || 3306
  end

  def username
    mycnf[:user] || 'root'
  end

  def database
    mycnf[:database] || 'test'
  end

  def password
    mycnf[:password] || ''
  end

  def socket
    mycnf[:socket] || nil
  end

  def start
    return if pid

    @pid = fork do
      exec mysqld, "--defaults-file=#{base_dir}/etc/my.cnf", '-user=root'
    end
    exit unless pid

    while !File.exists?(mycnf[:pid_file])
      raise 'failed to launch mysqld' if Process.waitpid(pid, 1) > 0
      sleep 1
    end

    db = MySQL::Database.new 'localhost', 'root', '', 'mysql', 3306, mycnf[:socket]
    db.execute_batch 'CREATE DATABASE IF NOT EXISTS test'
    db.close

    at_exit { stop }
  end

  def stop
    return unless pid

    Process.kill 'TERM', pid
    while Process.waitpid(pid) <= 0; end
    File.unlink mycnf[:pid_file] if File.exists? mycnf[:pid_file]
    @pid = nil
  end

  def setup
    if !Dir.exists?(base_dir)
      Dir.mkdir(base_dir)
      %w(etc var tmp).each {|subd| Dir.mkdir "#{base_dir}/#{subd}" }
    end

    File.open("#{base_dir}/etc/my.cnf", 'w') do |f|
      f.puts '[mysqld]'
      mycnf.each { |k, v| f.puts "#{k} = #{v}" }
    end

    `#{install_db_cmd}`
  end

  def mysqld_version
    `#{mysqld} --version`.chomp.match(/Ver\s+\b(\d+\.\d+\.\d+)\b/i)[1]
  end

  def install_db_cmd
    # see detail: http://dev.mysql.com/doc/relnotes/mysql/5.7/en/news-5-7-6.html
    current_version = VersionCmp.new mysqld_version
    deprecated_version = VersionCmp.new('5.7.6')

    cmd = if current_version >= deprecated_version
            "#{mysqld} --defaults-file='#{base_dir}/etc/my.cnf' --initialize-insecure --basedir='#{base_dir}' --datadir='#{mycnf[:datadir]}'"
          else
            mysql_base_dir = File.realpath(mysql_install_db).sub(/\/[^\/]+\/mysql_install_db$/, '')
            "#{mysql_install_db} --defaults-file='#{base_dir}/etc/my.cnf' --basedir=#{mysql_base_dir} --datadir='#{mycnf[:datadir]}'"
          end
    cmd
  end

  def _find_program(program)
    path = _get_path_of(program)
    raise "Couldn't find #{program}, please set appropriate $PATH" if path.empty?
    path
  end

  def _get_path_of(program)
    `which #{program} 2> /dev/null`.chomp
  end
end
