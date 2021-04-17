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

    new_girl_entity estore

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
