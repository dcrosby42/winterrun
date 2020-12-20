class Backgrounds
  attr_gtk

  def tick
    state.vport ||= state.new_entity_strict(:viewport, x: 0, y: 0, w: grid.w, h: grid.h)

    state.bgx ||= 0
    state.bgy ||= 0
    state.bgscale ||= 1.5

    state.bgscale = 1 if keyboard.key_down.zero
    state.bgscale += 0.1 if keyboard.key_down.equal_sign
    state.bgscale -= 0.1 if keyboard.key_down.hyphen

    movex = 2
    if keyboard.space
      movex = 10
    end
    state.vport.x += movex if keyboard.key_held.d
    state.vport.x -= movex if keyboard.key_held.a

    #
    # DRAW
    #

    outputs.background_color = [33, 32, 87]

    # outputs.sprites << [0, 0, BackgroundW, BackgroundH, BBackgrounds[3][:path]]
    outputs.sprites << ABackgrounds.flat_map do |bg|
      left = state.vport.x * bg[:parallax]
      right = left + state.vport.w
      ltx = (left / (BackgroundW * state.bgscale)).floor
      rtx = (right / (BackgroundW * state.bgscale)).floor

      (ltx..rtx).to_a.map do |tx|
        x = (BackgroundW * state.bgscale * tx) - (state.vport.x * bg[:parallax])
        [x, 0, BackgroundW * state.bgscale, BackgroundH * state.bgscale, bg[:path]]
      end
    end

    outputs.labels << { x: 0, y: 720, text: "viewport #{state.vport.x},#{state.vport.y},#{state.vport.w},#{state.vport.h}", r: 255, g: 255, b: 255 }
    outputs.labels << { x: 0, y: 700, text: "scale: #{state.bgscale} (#{BackgroundW * state.bgscale}, #{BackgroundH * state.bgscale})", r: 255, g: 255, b: 255 }
    outputs.labels << { x: 0, y: 680, text: "held: #{keyboard.key_held.truthy_keys.inspect}", r: 255, g: 255, b: 255 }
  end

  BackgroundW = 1421
  BackgroundH = 480

  Backgrounds = [
    "background2.png", "background layer1b.png", "background layer2.png", "background.png", "background layer0b.png", "background layer1.png", "background layer3b.png", "background layer0.png", "background layer2b.png", "background layer3.png",
  ].map do |f| "sprites/snowy_forest/Backgrounds/#{f}" end

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
end
