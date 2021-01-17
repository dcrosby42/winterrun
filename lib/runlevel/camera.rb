module RunLevel
  include Cedar
  extend Cedar::Helpers

  Camera = Component.new(:camera, { zoom: 1, follow: true })

  _cam_search = CompSearch.new(Camera, Pos)
  # CameraManualControlSystem = define_system(Camera, Pos) do |e, input, res|
  CameraManualControlSystem = lambda do |estore, input, res|
    e = estore.search(_cam_search).first || return

    if input.keyboard.pressed?(Gosu::KB_C) && input.keyboard.shift?
      e.camera.follow = !e.camera.follow
    end

    if e.camera.follow
      FollowerSystem.call(estore, input, res)
      return
    end

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
end
