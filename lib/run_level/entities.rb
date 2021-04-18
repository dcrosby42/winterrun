module RunLevel
  def initial_entities(estore)
    new_camera_entity estore

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
