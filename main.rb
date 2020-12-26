require "./config/environment"

require "modules/backgrounds"
require "modules/spritesheet"

Cedar::Game.new(
  root_module: Spritesheet,
  # root_module: Backgrounds,
  caption: "WinterRun",
  fullscreen: false,
).start!
