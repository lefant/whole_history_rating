require 'rake'
require 'rake/testtask'

task default: [:test_units]

desc 'Run basic tests'
Rake::TestTask.new('test_units') do |t|
  t.pattern = 'test/*_test.rb'
  # t.verbose = true
  t.warning = true
end

task 'assets:precompile' do
  puts 'assets:precompile'
end
