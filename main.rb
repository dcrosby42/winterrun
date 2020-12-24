require "./config/environment"

require "game"
require "modules/backgrounds"

Game.new(
  root_module: Backgrounds,
  caption: "WinterRun",
  fullscreen: false,
).start!
