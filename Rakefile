require 'rspec/core/rake_task'

task :default => :test

desc 'Run all specs'
RSpec::Core::RakeTask.new(:test) do |task|
  task.pattern = './spec/**/*_spec.rb'
  task.rspec_opts = '-fs --color'.split
end
