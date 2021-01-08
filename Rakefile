require "rake/testtask"
require "rspec/core/rake_task"

task default: "run"

desc "Run WinterRun game"
task :run do
  exec "bundle exec ruby main.rb"
end

desc "Scratch console prompt"
task :console do
  require "./config/environment"
  binding.pry
end

RSpec::Core::RakeTask.new(:spec)
task test: :spec
