require "ostruct"
require "draw_image"

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

  def initialState(opts = nil)
    opts ||= OpenStruct.new

    return OpenStruct.new({
             vport: OpenStruct.new({ x: 0, y: 0, w: opts.width, h: opts.height }),
             bgscale: 1.5,
           })
  end

  def initialResources
    res = Struct.new(:images, :fonts).new
    res.images = Hash.new do |h, key|
      h[key] = Gosu::Image.new(key, tileable: true, retro: true)
    end
    res.fonts = {}
    res.fonts[:default] = Gosu::Font.new(20)
    res
  end

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
      fx << Sidefx::ToggleFullscreen.new
    end

    [state, fx]
  end

  def draw(state, res)
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
        DrawImage.new(
          path: bg[:path],
          x: x,
          y: 0,
          z: ZOrder.BACKGROUND,
          scale_x: state.bgscale,
          scale_y: state.bgscale,
        )
      end
    end

    ss.each do |dimg|
      res.images[dimg.path].draw(dimg.x, dimg.y, dimg.z || 0, dimg.scale_x, dimg.scale_y)
    end

    bg_tile_ranges_str = bg_tile_ranges.map do |r| r.to_a.inspect end.join(" / ")
    res.fonts[:default].draw_text("bgtiles: #{bg_tile_ranges_str}", 0, 0, ZOrder.UI, state.bgscale, state.bgscale)
  end
end
