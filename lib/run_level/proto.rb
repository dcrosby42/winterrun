module RunLevel
  ProtoMolecule = Component.new(:proto_molecule, { name: "UNSET", data: nil })
  BackgroundLayer = Component.new(:background_layer, { layer: 0, xtile: 0 })

  BGW = 1421
  Scheme = {
    0 => { sprite_id: "bg_l0", paralax: 0.125, w: 1421 },
    1 => { sprite_id: "bg_l1", paralax: 0.25, w: 1421 },
    2 => { sprite_id: "bg_l2", paralax: 0.5, w: 1421 },
    3 => { sprite_id: "bg_l3", paralax: 1, w: 1421 },
  }

  def paralax_calc(x, w, factor, tile_w)
    left = (x * factor).to_i
    right = (left + w).to_i
    puts "#{left}, #{right}"
    t0 = left / tile_w
    tn = right / tile_w
    (t0..tn).map do |tx|
      (x * (1 - factor)).to_i + (tx * tile_w)
    end
  end

  ParalaxSystem = begin
      cam_search = CompSearch.new(Camera)
      # proto_search = CompSearch.new(ProtoMolecule)
      bg_search = CompSearch.new(BackgroundLayer)

      lambda do |estore, input, res|
        cam = estore.search(cam_search).first || return
        bgs = estore.search(bg_search)

        by_layer = bgs.inject({}) do |m, e|
          m[e.background_layer.layer] ||= []
          m[e.background_layer.layer] << e
        end

        Scheme.each do |layer, cfg|
          xs = paralax_calc(cam.pos.x, cam.camera.world_w, cfg[:paralax],cfg[:w])
          by_layer[layer]
        end
      end
    end
end
