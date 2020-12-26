require "ostruct"
require "component"

module Backgrounds
  extend self

  BackgroundW = 1421
  BackgroundH = 480

  ABackgrounds = [
    { path: "sprites/snowy_forest/Backgrounds/background layer0.png", parallax: 0.125 },
    { path: "sprites/snowy_forest/Backgrounds/background layer1.png", parallax: 0.25 },
    { path: "sprites/snowy_forest/Backgrounds/background layer2.png", parallax: 0.5 },
    { path: "sprites/snowy_forest/Backgrounds/background layer3.png", parallax: 1 },
  ]

  BBackgrounds = [
    { path: "sprites/snowy_forest/Backgrounds/background layer0b.png", parallax: 0.125 },
    { path: "sprites/snowy_forest/Backgrounds/background layer1b.png", parallax: 0.25 },
    { path: "sprites/snowy_forest/Backgrounds/background layer2b.png", parallax: 0.5 },
    { path: "sprites/snowy_forest/Backgrounds/background layer3b.png", parallax: 1 },
  ]

  ZOrder = OpenStruct.new({
    BACKGROUND: 0,
    UI: 5,
  })

  def new_state(opts = nil)
    opts ||= OpenStruct.new

    return OpenStruct.new({
             vport: OpenStruct.new({ x: 0, y: 0, w: opts.width, h: opts.height }),
             bgscale: 1.5,
             reload_timer: Timer.new({ limit: 1.5, loop: true }),
           })
  end

  # def load_resources(res)
  # end

  def update(state, input, res)
    state.bgscale = 1.5 if input.keyboard.pressed?(Gosu::KB_0)
    state.bgscale += 0.1 if input.keyboard.pressed?(Gosu::KB_EQUALS)
    state.bgscale -= 0.1 if input.keyboard.pressed?(Gosu::KB_MINUS)

    spd = 120
    spd = 600 if input.keyboard.shift?
    spd = 1000 if input.keyboard.alt?

    vpmove = 0
    vpmove = -(spd * input.time.dt) if input.keyboard.down?(Gosu::KB_LEFT)
    vpmove = (spd * input.time.dt) if input.keyboard.down?(Gosu::KB_RIGHT)
    state.vport.x += vpmove

    fx = []
    if input.keyboard.pressed?(Gosu::KB_F11)
      fx << Cedar::Sidefx::ToggleFullscreen.new
    end

    TimerSystem.new.update state.reload_timer, input

    if state.reload_timer.alarm
      fx << Cedar::Sidefx::Reload.new
    end

    [state, fx]
  end

  def draw(state, output, res)
    # Gosu.draw_rect(0, 0, state.vport.w, state.vport.h, Gosu::Color::BLUE, ZOrder.BACKGROUND, mode = :default)

    bg_tile_ranges = []
    ss = BBackgrounds.flat_map do |bg|
      left = state.vport.x * bg[:parallax]
      right = left + state.vport.w
      ltx = (left / (BackgroundW * state.bgscale)).floor
      rtx = (right / (BackgroundW * state.bgscale)).floor

      bg_tile_ranges << (ltx..rtx)
      (ltx..rtx).to_a.map do |tx|
        x = (BackgroundW * state.bgscale * tx) - (state.vport.x * bg[:parallax])
        Cedar::Draw::Image.new(
          path: bg[:path],
          x: x,
          y: 0,
          z: ZOrder.BACKGROUND,
          scale_x: state.bgscale,
          scale_y: state.bgscale,
        )
      end
    end
    output << ss

    # ss.each do |img|
    #   img.draw(res)
    # end

    bg_tile_ranges_str = bg_tile_ranges.map do |r| r.to_a.inspect end.join(" / ")
    label = Cedar::Draw::Label.new(text: bg_tile_ranges_str, z: ZOrder.UI, scale_x: state.bgscale, scale_y: state.bgscale)
    output << label
    # label.draw(res)
  end
end
