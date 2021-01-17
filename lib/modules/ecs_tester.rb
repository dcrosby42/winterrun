require "cedar/ecs"

module EcsTester
  extend self
  include Cedar
  extend Cedar::Helpers

  Girl = Component.new(:girl, { dir: :right, player: nil })
  Camera = Component.new(:camera, { zoom: 1 })

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

  CameraManualControlSystem = define_system(Camera, Pos) do |e, input, res|
    mx = 0
    my = 0
    if input.keyboard.down?(Gosu::KB_J) # down
      my = 1
    elsif input.keyboard.down?(Gosu::KB_K) # up
      my = -1
    end
    if input.keyboard.down?(Gosu::KB_H) # left
      mx = -1
    elsif input.keyboard.down?(Gosu::KB_L) # right
      mx = 1
    end
    spd = 100
    if input.keyboard.shift?
      spd *= 2
    end
    e.pos.x += mx * spd * input.time.dt
    e.pos.y += my * spd * input.time.dt

    if input.keyboard.pressed?(Gosu::KB_EQUALS)
      e.camera.zoom += 0.1
    elsif input.keyboard.pressed?(Gosu::KB_MINUS)
      e.camera.zoom -= 0.1
    end
    if input.keyboard.pressed?(Gosu::KB_0)
      e.camera.zoom = 1
    end
  end

  GirlRunSpeed = 100
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
    CameraManualControlSystem.call(estore, input, res)
  end

  def new_state
    estore = EntityStore.new
    estore.new_entity do |e|
      e.add Girl.new(dir: :right, player: 1)
      e.add Sprite.new(id: "girl_stand", scale_x: 1, scale_y: 1, center_x: 0.5, center_y: 0.8)
      e.add Anim.new(id: "girl_stand", factor: 1)
      e.add Pos.new(x: 100, y: 480, z: 1)
      e.add Vel.new
    end
    estore.new_entity do |e|
      e.add Sprite.new(id: "bg_l0", scale_x: 1, scale_y: 1)
      e.add Pos.new(x: 0, y: 0, z: 0)
    end
    estore.new_entity do |e|
      e.add Camera.new(zoom: 2)
      e.add Pos.new(x: 0, y: 240)
    end

    open_struct({
      estore: estore,
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
      name: "bg_l0",
      type: "image_sprite",
      paths: ["snowy_forest/Backgrounds/background layer0.png"],
    })
    res.sprites.load({
      name: "bg_l1",
      type: "image_sprite",
      paths: ["snowy_forest/Backgrounds/background layer1.png"],
    })
    res.sprites.load({
      name: "bg_l2",
      type: "image_sprite",
      paths: ["snowy_forest/Backgrounds/background layer2.png"],
    })
    res.sprites.load({
      name: "bg_l3",
      type: "image_sprite",
      paths: ["snowy_forest/Backgrounds/background layer3.png"],
    })
    # { path: "snowy_forest/Backgrounds/background layer0.png", parallax: 0.125 },
    # { path: "snowy_forest/Backgrounds/background layer1.png", parallax: 0.25 },
    # { path: "snowy_forest/Backgrounds/background layer2.png", parallax: 0.5 },
    # { path: "snowy_forest/Backgrounds/background layer3.png", parallax: 1 },
  end

  def update(state, input, res)
    MySystem.call(state.estore, input, res)
    state
  end

  def draw(state, output, res)
    @cam_search ||= CompSearch.new(Camera, Pos)
    @sprite_search ||= CompSearch.new(Pos, Sprite)

    cam = state.estore.search(@cam_search).first
    if cam
      output.graphics << Draw::Translate.new(-cam.pos.x, -cam.pos.y) do |tr|
        tr << Draw::Scale.new(cam.camera.zoom) do |g|
          state.estore.search(@sprite_search).each do |e|
            g << Draw::SheetSprite.new(
              sprite_id: e.sprite.id,
              sprite_frame: e.sprite.frame,
              x: e.pos.x,
              y: e.pos.y,
              z: e.pos.z,
              scale_x: e.sprite.scale_x,
              scale_y: e.sprite.scale_y,
              center_x: e.sprite.center_x,
              center_y: e.sprite.center_y,
            )
          end
        end
      end
    end
  end
end
