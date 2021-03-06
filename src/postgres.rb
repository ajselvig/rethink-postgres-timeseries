require 'pg'
require 'benchmark'

class Postgres

  def initialize(settings)
    @settings = settings
  end

  TABLE_DEF = <<TABLE
    (time timestamp NOT NULL, key_field character(8), value_field double precision)
TABLE

  TIME_FORMAT = '%Y-%m-%d %H:%M:%S'

  def open
    @conn = PG.connect(dbname: 'postgres')
    @conn.exec("CREATE DATABASE #{@settings.db_name}")
    begin
      @conn.exec("CREATE TABLE #{@settings.table_name} #{TABLE_DEF};")
    rescue
      # it already exists
      @conn.exec("TRUNCATE #{@settings.table_name};")
    end
    begin
      @conn.exec("CREATE INDEX #{@settings.key_field} ON #{@settings.table_name} (#{@settings.key_field});")
    rescue
      # it already exists
    end
    begin
      @conn.exec("CREATE INDEX time ON #{@settings.table_name} (time);")
    rescue
      # it already exists
    end
  end

  def close
    @conn.exec("DROP DATABASE #{@settings.db_name}")
    # @conn.close
  end

  def populate_initial
    now = Time.new(2010,1,1).to_i
    pings = 0.upto(@settings.num_initial).map do |i|
      time = Time.at(now + i, 0)
      @settings.random_ping time
    end
    @conn.prepare('insert_statement', "insert into #{@settings.table_name} (time, #{@settings.key_field}, value_field) values ($1::timestamp, $2, $3)")
    pings.each do |ping|
      @conn.exec_prepared('insert_statement', [ping[:time].strftime(TIME_FORMAT), ping[:key_field], ping[:value_field]])
    end
  end

  def insert_one
    ping = @settings.random_ping Time.now
    @conn.exec_prepared('insert_statement', [ping[:time].to_s, ping[:key_field], ping[:value_field]])
  end

  def get_by_key
    key = @settings.random_key
    records = @conn.exec("SELECT * FROM #{@settings.table_name} WHERE #{@settings.key_field} = '#{key}'").to_a
    # puts "  There are #{records.length} pings with key #{key}"
  end

  def get_by_time_range
    t = Time.new(2010,1,1).to_i + @settings.num_initial/2
    start = Time.at(t, 0)
    stop = Time.at(t + @settings.time_range, 0)
    records = @conn.exec("SELECT * FROM #{@settings.table_name} WHERE time BETWEEN '#{start.strftime(TIME_FORMAT)}'::timestamp AND '#{stop.strftime(TIME_FORMAT)}'::timestamp").to_a
    # puts "  There are #{records.length} pings in time range"
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
        x.report('Get pings by time range:') do
          get_by_time_range
        end
      end
    rescue Exception => ex
      puts "Error running postgres: #{ex.message}"
    ensure
      close
    end
  end

end