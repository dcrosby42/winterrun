module RunLevel
  include Cedar
  extend Cedar::Helpers

  Girl = Component.new(:girl, { dir: :right, player: nil })

  GirlRunSpeed = 100

  GirlSystem = define_system(Girl) do |e, input, res|
    speed_factor = case
      when input.keyboard.alt?
        3
      when input.keyboard.shift?
        1.5
      else
        1
      end

    dir = e.girl.dir

    touching_ground = e.pos.y >= 480
    if touching_ground
      if input.keyboard.down?(Gosu::KB_LEFT)
        e.girl.dir = :left
        e.vel.dx = -GirlRunSpeed * speed_factor
        e.sprite.scale_x = -(e.sprite.scale_x.abs)
      elsif input.keyboard.down?(Gosu::KB_RIGHT)
        e.girl.dir = :right
        e.vel.dx = GirlRunSpeed * speed_factor
        e.sprite.scale_x = e.sprite.scale_x.abs
      elsif input.keyboard.down?(Gosu::KB_SPACE)
        e.vel.dy -= 20
      else
        e.vel.dx = 0
      end
    else
      if e.pos.y >= 480
        puts "touch"
        e.vel.dy = 0
        e.pos.y = 480
      else
        puts "fall #{e.pos.y}"
        e.vel.dy += 1
      end
    end

    anim_id = e.vel.dx == 0 ? "girl_stand" : "girl_run"
    if e.anim.id != anim_id or e.girl.dir != dir
      e.anim.id = anim_id
      e.anim.t = 0
    end
    e.anim.factor = speed_factor
  end
end
