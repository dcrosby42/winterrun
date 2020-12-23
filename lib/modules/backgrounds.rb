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
  })

  def initialState(opts = OpenStruct.new)
    opts.w ||= 640
    opts.h ||= 480

    res = Struct.new(:images).new
    res.images = Hash.new do |h, key|
      h[key] = Gosu::Image.new(key, tileable: true, retro: true)
    end

    return OpenStruct.new({
             vport: OpenStruct.new({ x: 0, y: 0, w: opts.w, h: opts.h }),
             bgscale: 1.5,
             res: res,
           })
  end

  def update(state, input)
    # state.bgscale = 1 if keyboard.key_down.zero
    # state.bgscale += 0.1 if keyboard.key_down.equal_sign
    # state.bgscale -= 0.1 if keyboard.key_down.hyphen

    spd = 2
    vpmove = 0
    vpmove = -spd if Gosu.button_down? Gosu::KB_LEFT
    vpmove = spd if Gosu.button_down? Gosu::KB_RIGHT
    if Gosu.button_down? Gosu::KB_LEFT_SHIFT
      puts "Shift"
    end
    # if keyboard.space
    #   movex = 10
    # end
    state.vport.x += vpmove

    state
  end

  def draw(state)
    # Gosu.draw_rect(0, 0, state.vport.w, state.vport.h, Gosu::Color::BLUE, ZOrder.BACKGROUND, mode = :default)

    # # outputs.sprites << [0, 0, BackgroundW, BackgroundH, BBackgrounds[3][:path]]
    ss = ABackgrounds.flat_map do |bg|
      left = state.vport.x * bg[:parallax]
      right = left + state.vport.w
      ltx = (left / (BackgroundW * state.bgscale)).floor
      rtx = (right / (BackgroundW * state.bgscale)).floor

      (ltx..rtx).to_a.map do |tx|
        x = (BackgroundW * state.bgscale * tx) - (state.vport.x * bg[:parallax])
        DrawImage.new(
          path: bg[:path],
          x: x, y: 0, z: ZOrder.BACKGROUND,
          scale_x: state.bgscale, scale_y: state.bgscale,
        )
      end
    end

    # outputs.labels << { x: 0, y: 720, text: "viewport #{state.vport.x},#{state.vport.y},#{state.vport.w},#{state.vport.h}", r: 255, g: 255, b: 255 }
    # outputs.labels << { x: 0, y: 700, text: "scale: #{state.bgscale} (#{BackgroundW * state.bgscale}, #{BackgroundH * state.bgscale})", r: 255, g: 255, b: 255 }
    # outputs.labels << { x: 0, y: 680, text: "held: #{keyboard.key_held.truthy_keys.inspect}", r: 255, g: 255, b: 255 }

    ss.each do |dimg|
      state.res.images[dimg.path].draw(dimg.x, dimg.y, dimg.z || 0, dimg.scale_x, dimg.scale_y)
    end
  end
end
