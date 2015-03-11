require 'rake'

require_relative 'src/settings'
require_relative 'src/rethink'

desc 'Run the benchmarks'
task :run do

  settings = Settings.new

  rethink = Rethink.new settings
  rethink.run

end