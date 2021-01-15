require "cedar/ecs"

module EcsTester
  extend self
  include Cedar
  extend Cedar::Helpers

  Girl = Component.new(:girl, { dir: :right, player: nil, anim_t: 0 })

  MotionSystem = define_system(Vel, Pos) do |e, input, res|
    e.pos.x += e.vel.dx * input.time.dt
    e.pos.y += e.vel.dy * input.time.dt
  end

  GirlRunSpeed = 200
  GirlFps = 200
  GirlSystem = define_system(Girl) do |e, input, res|
    dir = e.girl.dir
    if input.keyboard.down?(Gosu::KB_LEFT)
      e.girl.dir = :left
      e.vel.dx = -GirlRunSpeed
      e.sprite.scale_x = -(e.sprite.scale_x.abs)
    elsif input.keyboard.down?(Gosu::KB_RIGHT)
      e.girl.dir = :right
      e.vel.dx = GirlRunSpeed
      e.sprite.scale_x = e.sprite.scale_x.abs
    else
      e.vel.dx = 0
    end

    sprite_id = e.vel.dx == 0 ? "girl_stand" : "girl_run"
    if e.sprite.id != sprite_id or e.girl.dir != dir
      e.sprite.id = sprite_id
      e.sprite.frame = 0
      e.girl.anim_t = 0
    else
      e.girl.anim_t += input.time.dt
      # puts "e.girl.anim_t: #{e.girl.anim_t}"
    end
    sprite = res.sprites[sprite_id]
    # puts "sprite: #{sprite.inspect}"
    e.sprite.frame = (e.girl.anim_t / (1.0 / GirlFps)).floor % sprite.frame_count
    # e.sprite.frame = (e.girl.anim_t / (1.0 / GirlFps)).floor % sprite.frame_count
    puts "e.sprite.frame: #{e.sprite.frame}"
  end

  MySystem = lambda do |estore, input, res|
    GirlSystem.call(estore, input, res)
    MotionSystem.call(estore, input, res)
  end

  def new_state
    state = open_struct({
      estore: EntityStore.new,
      system: MySystem,
    })
    state.estore.new_entity do |e|
      e.add Girl.new(dir: :right, player: 1)
      e.add Sprite.new(id: "girl_stand", scale_x: 2, scale_y: 2)
      e.add Pos.new(x: 100, y: 100)
      e.add Vel.new
    end
    state
  end

  def load_resources(state, res)
    res.sprites.load("files/girl_sprite.json")
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
