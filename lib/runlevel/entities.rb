module RunLevel
  def initial_entities(estore)
    estore.new_entity do |e|
      e.add Camera.new(zoom: 2)
      e.add Pos.new(x: 0, y: 240)
      e.add Follower.new(target_name: "girl")
      e.add DebugWatch.new(label: "cam", watches: { pos: [:x, :y], camera: [:zoom, :follow] })
    end

    estore.new_entity do |e|
      e.add Girl.new(dir: :right, player: 1)
      e.add Sprite.new(id: "girl_stand", scale_x: 1, scale_y: 1, center_x: 0.5, center_y: 0.8)
      e.add Anim.new(id: "girl_stand", factor: 1)
      e.add Pos.new(x: 0, y: 480, z: 10)
      e.add Vel.new
      e.add FollowTarget.new(name: "girl")
      e.add DebugWatch.new(label: "girl", watches: [[:pos, :x]])
    end

    estore.new_entity do |e|
      e.add Sprite.new(id: "bg_l0")
      e.add Pos.new(x: 0, y: 0, z: 0)
    end
    estore.new_entity do |e|
      e.add Sprite.new(id: "bg_l1")
      e.add Pos.new(x: 0, y: 0, z: 1)
    end
    estore.new_entity do |e|
      e.add Sprite.new(id: "bg_l2")
      e.add Pos.new(x: 0, y: 0, z: 3)
    end
    estore.new_entity do |e|
      e.add Sprite.new(id: "bg_l3")
      e.add Pos.new(x: 0, y: 0, z: 4)
    end
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
end
