module RunLevel
  def initial_entities(estore)
    estore.new_entity do |e|
      e.add Camera.new(zoom: 2, follow: true)
      e.add Pos.new(x: 0, y: 240)
      e.add Follower.new(target_name: "girl", off_x: 200, off_y: 360)
      watches = {
        pos: [:x, :y],
        camera: [:zoom, :follow, :native_x, :native_y, :native_w, :native_h, :world_w, :world_h],
        follower: [:off_x, :off_y],
      }
      e.add DebugWatch.new(label: "cam", watches: watches)
    end

    estore.new_entity do |e|
      e.add Girl.new(dir: :right, player: 1)
      e.add Sprite.new(id: "girl_stand", scale_x: 1, scale_y: 1, center_x: 0.5, center_y: 0.8)
      e.add Anim.new(id: "girl_stand", factor: 1)
      e.add Pos.new(x: 0, y: 480, z: 10)
      e.add Vel.new
      e.add FollowTarget.new(name: "girl")
      e.add DebugWatch.new(label: "girl", watches: { pos: [:x, :y], vel: [:dx, :dy] })
    end

    estore.new_entity do |e|
      e.add Placeholder.new(name: "Background", data: {})
      # e.add DebugWatch.new(label: "dbg", watches: { placeholder: [:name, :data] })
    end
  end

  def load_resources(state, res)
    res.configure list_resources
  end

  def list_resources
    [
      "sprites/girl_sprites.json",
      "sprites/snowy_background.json",
    ]
  end
end
