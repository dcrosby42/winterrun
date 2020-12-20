require "app/backgrounds.rb"
$top_module = Backgrounds.new

def tick(args)
  $top_module.args = args
  $top_module.tick
end
