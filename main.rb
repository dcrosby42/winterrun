require "./config/environment"

require "modules/backgrounds"

Cedar::Game.new(
  root_module: Backgrounds,
  caption: "WinterRun",
  fullscreen: false,
).start!
