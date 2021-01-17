require "cedar/ecs"

module EcsTester
  extend self
  include Cedar
  extend Cedar::Helpers

  Girl = Component.new(:girl, { dir: :right, player: nil })

  MotionSystem = define_system(Vel, Pos) do |e, input, res|
    e.pos.x += e.vel.dx * input.time.dt
    e.pos.y += e.vel.dy * input.time.dt
  end

  AnimSystem = define_system(Anim, Sprite) do |e, input, res|
    e.anim.t += (input.time.dt * e.anim.factor)
    anim = res.anims[e.anim.id]
    sprite_id, frame_id = anim.call(e.anim.t)
    e.sprite.id = sprite_id
    e.sprite.frame = frame_id
  end

  GirlRunSpeed = 200
  GirlFps = 24
  GirlSystem = define_system(Girl) do |e, input, res|
    dir = e.girl.dir
    factor = input.keyboard.shift? ? 1.5 : 1
    if input.keyboard.down?(Gosu::KB_LEFT)
      e.girl.dir = :left
      e.vel.dx = -GirlRunSpeed * factor
      e.sprite.scale_x = -(e.sprite.scale_x.abs)
    elsif input.keyboard.down?(Gosu::KB_RIGHT)
      e.girl.dir = :right
      e.vel.dx = GirlRunSpeed * factor
      e.sprite.scale_x = e.sprite.scale_x.abs
    else
      e.vel.dx = 0
    end

    anim_id = e.vel.dx == 0 ? "girl_stand" : "girl_run"
    if e.anim.id != anim_id or e.girl.dir != dir
      e.anim.id = anim_id
      e.anim.t = 0
    end
    e.anim.factor = factor
  end

  MySystem = lambda do |estore, input, res|
    GirlSystem.call(estore, input, res)
    AnimSystem.call(estore, input, res)
    MotionSystem.call(estore, input, res)
  end

  def new_state
    estore = EntityStore.new
    estore.new_entity do |e|
      e.add Girl.new(dir: :right, player: 1)
      e.add Sprite.new(id: "girl_stand", scale_x: 2, scale_y: 2)
      e.add Anim.new(id: "girl_stand", factor: 1)
      e.add Pos.new(x: 100, y: 100)
      e.add Vel.new
    end
    estore.new_entity do |e|
      e.add Sprite.new(id: "bg1")
    end

    open_struct({
      estore: estore,
      system: MySystem,
    })
  end

  def load_resources(state, res)
    res.sprites.load("girl_sprite.json")
    res.anims["girl_run"] = lambda do |t|
      ct = res.sprites["girl_run"].tile_grid.count
      frame = (t * GirlFps).to_i % ct
      ["girl_run", frame]
    end
    res.anims["girl_stand"] = lambda do |t|
      ct = res.sprites["girl_stand"].tile_grid.count
      frame = (t * GirlFps).to_i % ct
      ["girl_stand", frame]
    end
    res.sprites.load({
      name: "bg1",
      type: "image_sprite",
      paths: ["snowy_forest/Backgrounds/background layer3.png"],
    })
    # { path: "snowy_forest/Backgrounds/background layer0.png", parallax: 0.125 },
    # { path: "snowy_forest/Backgrounds/background layer1.png", parallax: 0.25 },
    # { path: "snowy_forest/Backgrounds/background layer2.png", parallax: 0.5 },
    # { path: "snowy_forest/Backgrounds/background layer3.png", parallax: 1 },
  end

  def update(state, input, res)
    # state.system.call(state.estore, input, res)
    MySystem.call(state.estore, input, res)
    state
  end

  DrawSystem = define_system(Pos) do |e, output, res|
    if e.sprite
      output.graphics << Draw::SheetSprite.new(
        sprite_id: e.sprite.id,
        sprite_frame: e.sprite.frame,
        x: e.pos.x,
        y: e.pos.y,
        scale_x: e.sprite.scale_x,
        scale_y: e.sprite.scale_y,
      )
    end
  end

  def draw(state, output, res)
    DrawSystem.call(state.estore, output, res)
  end
end
