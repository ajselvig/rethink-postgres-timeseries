require 'rethinkdb'
require 'benchmark'

class Rethink
  include RethinkDB::Shortcuts

  def initialize(settings)
    @settings = settings
  end

  def open
    @conn = r.connect(host: 'localhost', port: 28015)
    unless r.db_list.run(@conn).index @settings.db_name
      r.db_create(@settings.db_name).run(@conn)
    end
    unless r.db(@settings.db_name).table_list.run(@conn).index @settings.table_name
      r.db(@settings.db_name).table_create(@settings.table_name).run(@conn)
    end
    unless r.db(@settings.db_name).table(@settings.table_name).index_list.run(@conn).index @settings.key_field
      r.db(@settings.db_name).table(@settings.table_name).index_create(@settings.key_field).run(@conn)
    end
  end

  def close
    r.db_drop(@settings.db_name).run(@conn)
  end

  def populate_initial
    now = r.time(2010,1,1, 'Z').run(@conn).to_i
    pings = 0.upto(@settings.num_initial).map do |i|
      time = r.epoch_time(now + i).run(@conn)
      @settings.random_ping time
    end
    r.db(@settings.db_name).table(@settings.table_name)
        .insert(pings).run(@conn)
  end

  def insert_one
    ping = @settings.random_ping r.now.run(@conn)
    r.db(@settings.db_name).table(@settings.table_name)
        .insert(ping).run(@conn)
  end

  def get_by_key
    key = @settings.random_key
    records = r.db(@settings.db_name).table(@settings.table_name)
        .get_all(key, index: @settings.key_field).run(@conn).to_a
    # puts "  There are #{records.length} pings with key #{key}"
  end

  def run
    begin
      Benchmark.bm(30) do |x|
        x.report('Create table and index:') do
          open
        end
        x.report("Populate #{@settings.num_initial} initial pings:") do
          populate_initial
        end
        x.report('Insert single ping:') do
          insert_one
        end
        x.report('Get pings by key:') do
          get_by_key
        end
      end
    rescue Exception => ex
      puts "Error running rethink: #{ex.message}"
    ensure
      close
    end
  end

end