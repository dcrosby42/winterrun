module RunLevel
  include Cedar
  extend Cedar::Helpers

  Camera = Component.new(:camera, { zoom: 1, follow: true, native_x: 0, native_y: 0, native_w: 0, native_h: 0, world_w: 0, world_h: 0 })

  def new_camera_entity(estore)
    estore.new_entity do |e|
      e.add Camera.new(zoom: 2, follow: true)
      e.add Pos.new(x: 0, y: 240)
      e.add Follower.new(target_name: "girl", off_x: 200, off_y: 360, min_y: 120)
      watches = {
        pos: [:x, :y],
        camera: [:zoom, :follow, :native_x, :native_y, :native_w, :native_h, :world_w, :world_h],
        follower: [:off_x, :off_y],
      }
      e.add DebugWatch.new(label: "cam", watches: watches)
    end
  end

  # CameraSystem = define_system(Camera, Pos) do |e, input, res|
  CamSearch = EntityFilter.new(Camera, Pos)
  CameraSystem = lambda do |estore, input, res|
    e = estore.search(CamSearch).first || return

    # Keyboard input: Shift-F toggles "follow" behavior
    if input.keyboard.pressed?(Gosu::KB_F) && input.keyboard.shift?
      if e.has?(:follower)
        e.follower.on = !e.follower.on
      end
    end

    # Keyboard zoom control: 0, -, +
    if input.keyboard.pressed?(Gosu::KB_EQUALS)
      e.camera.zoom += 0.1
    elsif input.keyboard.pressed?(Gosu::KB_MINUS)
      e.camera.zoom -= 0.1
    end
    if input.keyboard.pressed?(Gosu::KB_0)
      e.camera.zoom = 1
    end

    if e.has?(:follower) and e.follower.on
      # Adjust following height based on zoom level, to keep our target from disappearing off the bottom:
      e.follower.off_y = [input.window.height / e.camera.zoom, 360].min
      e.follower.min_y = 480 - e.follower.off_y

      # This will update camera pos values based on target entity:
      FollowerSystem.call(estore, input, res)
    else
      # WASD keys move the camera
      mx = 0
      my = 0
      if input.keyboard.down?(Gosu::KB_S) # down
        my = 1
      elsif input.keyboard.down?(Gosu::KB_W) # up
        my = -1
      end
      if input.keyboard.down?(Gosu::KB_A) # left
        mx = -1
      elsif input.keyboard.down?(Gosu::KB_D) # right
        mx = 1
      end
      spd = 100
      if input.keyboard.shift?
        spd *= 2
      end
      e.pos.x += mx * spd * input.time.dt
      e.pos.y += my * spd * input.time.dt
    end

    update_native_coords e, input # remove once initial dev is done?
  end

  # um. I think this was just for debugs...
  def update_native_coords(e, input)
    e.camera.native_x = e.pos.x * e.camera.zoom
    e.camera.native_y = e.pos.y * e.camera.zoom
    e.camera.native_w = input.window.width
    e.camera.native_h = input.window.height
    e.camera.world_w = e.camera.native_w / e.camera.zoom
    e.camera.world_h = e.camera.native_h / e.camera.zoom
  end
end
