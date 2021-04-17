module RunLevel
  include Cedar
  extend Cedar::Helpers

  Girl = Component.new(:girl, {
    player: nil,
    dir: :right,
    touching_down: false,
  })
  Moveable = Component.new(:moveable, {
    touching_down: false,
  })

  GirlRunSpeed = 100

  def self.new_girl_entity(estore)
    estore.new_entity do |e|
      e.add Girl.new(dir: :right, player: 1)
      e.add Moveable.new({})
      e.add Sprite.new(id: "girl_stand", scale_x: 1, scale_y: 1, center_x: 0.5, center_y: 0.8)
      e.add Anim.new(id: "girl_stand", factor: 1)
      e.add Pos.new(x: 0, y: 400, z: 10)
      e.add Vel.new
      e.add FollowTarget.new(name: "girl")
      e.add DebugWatch.new(label: "girl", watches: { pos: [:x, :y], vel: [:dx, :dy] })
    end
  end

  GirlSystem = define_system(Girl) do |e, input, res|
    # APPLY CONTROLS TO CHARACTER
    speed_factor = case
      when input.keyboard.alt?
        3
      when input.keyboard.shift?
        1.5
      else
        1
      end

    dir = e.girl.dir

    if e.girl.touching_down
      if input.keyboard.down?(Gosu::KB_LEFT)
        e.girl.dir = :left
        e.vel.dx = -GirlRunSpeed * speed_factor
        e.sprite.scale_x = -(e.sprite.scale_x.abs)
      elsif input.keyboard.down?(Gosu::KB_RIGHT)
        e.girl.dir = :right
        e.vel.dx = GirlRunSpeed * speed_factor
        e.sprite.scale_x = e.sprite.scale_x.abs
      elsif input.keyboard.pressed?(Gosu::KB_SPACE)
        e.vel.dy -= 90
      else
        e.vel.dy = 0
        e.vel.dx = 0
      end
    else
      e.vel.dy += 4.5
    end

    # SELECT ANIMATION

    anim_id = e.vel.dx == 0 ? "girl_stand" : "girl_run"
    if e.anim.id != anim_id or e.girl.dir != dir
      e.anim.id = anim_id
      e.anim.t = 0
    end
    e.anim.factor = speed_factor

    # MOTION
  end

  MapLeftmost = 0
  MapRightmost = 400 # fixme
  MapTop = 0
  MapBottom = 480

  # (TODO move this somewhere helpful)
  def self.clamp(val, min, max)
    return min if val < min
    return max if val > max
    val
  end

  MotionSystem = define_system(Moveable, Vel, Pos) do |e, input, res|
    dx = e.vel.dx * input.time.dt
    dy = e.vel.dy * input.time.dt

    e.pos.x = clamp(e.pos.x + dx, MapLeftmost, MapRightmost)
    e.pos.y = clamp(e.pos.y + dy, MapTop, MapBottom)
  end
end
