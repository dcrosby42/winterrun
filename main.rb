require "./config/environment"

require "modules/bg_tester"
require "modules/spritesheet"

Cedar::Game.new(
  # root_module: Spritesheet,
  root_module: BgTester,
  caption: "WinterRun",
  fullscreen: false,
).start!
