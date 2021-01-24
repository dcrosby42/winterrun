module RunLevel
  include Cedar
  extend Cedar::Helpers

  Girl = Component.new(:girl, { dir: :right, player: nil })

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
end
