require "ostruct"
require "component"

module BgTester
  extend self

  BackgroundW = 1421
  BackgroundH = 480

  ABackgrounds = [
    { path: "snowy_forest/Backgrounds/background layer0.png", parallax: 0.125 },
    { path: "snowy_forest/Backgrounds/background layer1.png", parallax: 0.25 },
    { path: "snowy_forest/Backgrounds/background layer2.png", parallax: 0.5 },
    { path: "snowy_forest/Backgrounds/background layer3.png", parallax: 1 },
  ]

  BBackgrounds = [
    { path: "snowy_forest/Backgrounds/background layer0b.png", parallax: 0.125 },
    { path: "snowy_forest/Backgrounds/background layer1b.png", parallax: 0.25 },
    { path: "snowy_forest/Backgrounds/background layer2b.png", parallax: 0.5 },
    { path: "snowy_forest/Backgrounds/background layer3b.png", parallax: 1 },
  ]

  ZOrder = OpenStruct.new({
    BACKGROUND: 0,
    UI: 5,
  })

  def new_state
    return OpenStruct.new({
             vport: Cedar::Shape::Rect.new(x: 0, y: 0, w: 0, h: 0),
             scale: 1.0,
           })
  end

  def update(state, input, res)
    state.vport.w = input.window.width
    state.vport.h = input.window.height

    state.scale = 1.0 if input.keyboard.pressed?(Gosu::KB_0)
    state.scale += 0.02 if input.keyboard.down?(Gosu::KB_EQUALS)
    state.scale -= 0.02 if input.keyboard.down?(Gosu::KB_MINUS)

    spd = 120
    spd = 600 if input.keyboard.shift?
    spd = 1000 if input.keyboard.alt?

    vpmove = 0
    vpmove = -(spd * input.time.dt) if input.keyboard.down?(Gosu::KB_LEFT)
    vpmove = (spd * input.time.dt) if input.keyboard.down?(Gosu::KB_RIGHT)
    state.vport.x += vpmove
    state
  end

  def draw(state, output, res)
    # dbgs = []
    ss = BBackgrounds.flat_map do |bg|
      left = state.vport.x * bg[:parallax]
      right = left + (state.vport.w / state.scale)
      ltx = (left / BackgroundW).floor
      rtx = (right / BackgroundW).floor

      # dbg = { left: left.to_i, right: right.to_i, ltx: ltx, rtx: rtx, xs: [] }
      # dbgs << dbg
      (ltx..rtx).to_a.map do |tx|
        x = (BackgroundW * tx) - (state.vport.x * bg[:parallax])
        # dbg[:xs] << x.to_i
        Cedar::Draw::Image.new(
          path: bg[:path],
          x: x,
          y: 0,
          z: ZOrder.BACKGROUND,
        )
      end
    end
    # dbglines = dbgs.map(&:inspect)

    # Draw all the background tiles
    zoomed = Cedar::Draw::ScaleTransform.new(state.scale)
    zoomed << ss
    output.graphics << zoomed

    # Draw debug info
    # dbglines << "scale=#{state.scale}" #" left=#{left} right=#{right}"
    # y = 0
    # dbglines.each do |line|
    #   output.graphics << Cedar::Draw::Label.new(text: line, y: y, z: ZOrder.UI)
    #   y += 20
    # end
  end
end
