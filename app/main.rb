require "app/image_browser.rb"

$top_module = ImageBrowser.new

def tick(args)
  $top_module.args = args
  $top_module.tick
end
