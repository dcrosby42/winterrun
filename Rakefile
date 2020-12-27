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
