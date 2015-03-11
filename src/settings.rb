class Settings

  attr_reader :num_initial, :db_name, :table_name, :key_field, :time_range

  def initialize
    @num_initial = 500_000
    @db_name = 'time_series_benchmark'
    @table_name = 'pings'
    @prng = Random.new
    @keys = 12.times.map { (0...8).map{ (65 + @prng.rand(26)).chr }.join }
    @key_field = 'key_field'
    @time_range = 10000
  end

  def random_key
    @keys[ @prng.rand(@keys.length-1).round ]
  end

  def random_ping(time)
    {
        time: time,
        key_field: random_key,
        value_field: @prng.rand()
    }
  end

end