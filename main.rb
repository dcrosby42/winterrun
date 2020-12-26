require "./config/environment"

require "modules/switcher"

Cedar::Game.new(
  root_module: Switcher,
  caption: "WinterRun",
  fullscreen: false,
).start!
