require 'rake'

require_relative 'src/settings'
require_relative 'src/rethink'
require_relative 'src/postgres'

desc 'Run the benchmarks'
task :run do

  settings = Settings.new

  puts '## RethinkDB Benchmark ##'
  rethink = Rethink.new settings
  rethink.run
  
  puts ''
  puts '## PostgresQL Benchmark ##'
  postgres = Postgres.new settings
  postgres.run

end