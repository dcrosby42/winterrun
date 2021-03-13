module RunLevel
  ProtoMolecule = Component.new(:proto_molecule, { name: "UNSET", data: nil })
  BackgroundLayer = Component.new(:background_layer, { layer: 0, xtile: 0 })

  BGW = 1421 # hardcoded bg image width.  Could proly get this from resources
  Scheme = {
    0 => { sprite_id: "bg_l0", paralax: 0.125, w: 1421 },
    1 => { sprite_id: "bg_l1", paralax: 0.25, w: 1421 },
    2 => { sprite_id: "bg_l2", paralax: 0.5, w: 1421 },
    3 => { sprite_id: "bg_l3", paralax: 1, w: 1421 },
  }

  # paralax_calc determines where to position one or more "tiles" to create proper paralax offset.
  # Returns an array of world-relative x coords to place the image tiles at.
  # x: camera leftmost
  # w: camera view width
  # factor: paralax factor.  1 means 1-1 with camera motion (no paralax), 0 means no motion (infinite paralax)
  # tile_w: width of one bg image tile.
  def paralax_calc(x, w, factor, tile_w)
    left = (x * factor).to_i
    right = (left + w).to_i
    t0 = left / tile_w
    tn = right / tile_w
    (t0..tn).map do |tx|
      (x * (1 - factor)).to_i + (tx * tile_w)
    end
  end

  ParalaxSystem = begin
      cam_search = CompSearch.new(Camera)
      proto_search = CompSearch.new(ProtoMolecule)
      bg_search = CompSearch.new(BackgroundLayer)

      lambda do |estore, input, res|
        cam = estore.search(cam_search).first || return
        bgs = estore.search(bg_search)
        pe = estore.search(proto_search).first

        # Organize each BackgroundLayer entity, keyed by layer. Could be multiple ents per layer.
        by_layer = bgs.inject(Hash.new do |h, k| h[k] = [] end) do |m, e|
          m[e.background_layer.layer] << e
          m
        end

        # Ensure each list of ents per layer is in ascending x order
        # (may not be necessary tbh)
        by_layer.each do |layer, es|
          es.sort_by! do |e| e.pos.x end
        end

        # Iterate through each paralax layer definition:
        Scheme.each do |layer, cfg| # layer is an int [0,1,2,3]
          # Determine the x coords for 0 or more bg images based on camera location and paralax factor
          xs = paralax_calc(cam.pos.x, cam.camera.world_w, cfg[:paralax], cfg[:w])

          # deleteme: debugging
          pe.proto_molecule.data[layer] = xs

          # Arrange bg ents based on the current x coords.
          # Modify or add or remove entities as needed
          es = by_layer[layer]
          xs.each.with_index do |x, i|
            e = es[i]
            if e
              # There's already a background entity for us to move:
              e.pos.x = x
            else
              # We're short on entities, make a new one:
              estore.new_entity do |e|
                e.add Sprite.new(id: cfg[:sprite_id])
                e.add Pos.new(x: x, y: 0, z: layer)
                e.add BackgroundLayer.new(layer: layer)
              end
            end
          end
          if es.length > xs.length
            # This layer has extra entities we can drop
            es[x.length..-1].each do |e|
              estore.destroy_entity e
            end
          end
        end # Scheme.each
      end # lambda
    end
end
