class ImageBrowser
  attr_gtk

  # class PicSprite
  #   attr_sprite

  #   def initialize(pic, opts = {})
  #     self.w = pic.w * (opts.scale || 1)
  #     self.h = pic.h * (opts.scale || 1)
  #   end
  # end

  def tick
    # state.bg = state.new_entity(:pic, background)
    # path: "sprites/snowy_forest/Backgrounds/background.png",
    # w: 1421,
    # h: 480)

    state.bgx ||= 0
    state.bgy ||= 0
    state.bgi ||= 0
    state.bgscale ||= 1

    state.bgi = (state.bgi + 1).mod(Backgrounds.length) if keyboard.key_down.space
    state.bgscale = 1 if keyboard.key_down.zero
    state.bgscale += 0.1 if keyboard.key_down.equal_sign
    state.bgscale -= 0.1 if keyboard.key_down.hyphen

    movex = 1
    if keyboard.shift
      movex = 10
    end

    state.bgx += movex if keyboard.key_held.right
    state.bgx -= movex if keyboard.key_held.left

    bgpath = Backgrounds[state.bgi]

    #
    # DRAW
    #

    outputs.background_color = [33, 32, 87]

    outputs.sprites << [state.bgx, 0, BackgroundW * state.bgscale, BackgroundH * state.bgscale, bgpath]

    # outputs.primitives << PicSprite.new(state.bg)

    outputs.labels << { x: 0, y: 720, text: "grid w,h: #{grid.w}, #{grid.h}", r: 255, g: 255, b: 255 }
    outputs.labels << { x: 0, y: 700, text: "Backgrounds[#{state.bgi}]: #{bgpath}", r: 255, g: 255, b: 255 }
    outputs.labels << { x: 0, y: 680, text: "scale: #{state.bgscale} (#{BackgroundW * state.bgscale}, #{BackgroundH * state.bgscale}=", r: 255, g: 255, b: 255 }
  end

  Backgrounds = [
    "background2.png", "background layer1b.png", "background layer2.png", "background.png", "background layer0b.png", "background layer1.png", "background layer3b.png", "background layer0.png", "background layer2b.png", "background layer3.png",
  ].map do |f| "sprites/snowy_forest/Backgrounds/#{f}" end

  BackgroundW = 1421
  BackgroundH = 480

  def background
    {
      path: "sprites/snowy_forest/Backgrounds/background.png",
      w: 1421,
      h: 480,
    }
  end

  def background2
    {
      path: "sprites/snowy_forest/Backgrounds/background2.png",
      w: 1421,
      h: 480,
    }
  end
end
