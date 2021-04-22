module RunLevel
  BackgroundLayer = Component.new(:background_layer, { layer: 0, xtile: 0 })

  BGW = 1421 # hardcoded bg image width.  Could proly get this from resources
  Scheme = {
    0 => { sprite_id: "bg_l0", paralax: 0.1, w: 1421 },
    1 => { sprite_id: "bg_l1", paralax: 0.2, w: 1421 },
    2 => { sprite_id: "bg_l2", paralax: 0.4, w: 1421 },
    3 => { sprite_id: "bg_l3", paralax: 0.7, w: 1421 },
  }

  # paralax_calc determines where to position one or more "tiles" to create proper paralax offset.
  # Returns an array of world-relative x coords to place the image tiles at.
  # x: camera leftmost
  # w: camera view width
  # factor: paralax factor.  1 means 1-1 with camera motion (no paralax), 0 means no motion (infinite paralax)
  # tile_w: width of one bg image tile.
  def paralax_calc(x, w, factor, tile_w)
    left = (x * factor)
    right = (left + w)
    t0 = left.to_i / tile_w
    tn = right.to_i / tile_w
    (t0..tn).map do |tx|
      (x * (1.0 - factor)) + (tx * tile_w)
    end
  end

  ParalaxBackgroundSystem = begin
      cam_search = EntityFilter.new(Camera)
      bg_search = EntityFilter.new(BackgroundLayer)

      lambda do |estore, input, res|
        cam = estore.search(cam_search).first || return
        bgs = estore.search(bg_search)
        # phe = estore.search(placeholder_search).find do |e| e.placeholder.name == "Background" end # deleteme debugging

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
          # with_placeholder(estore, "Background") do |h|
          #   h.data[layer] = xs
          # end

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
            es[xs.length..-1].each do |e|
              estore.destroy_entity e
            end
          end
        end # Scheme.each
      end # lambda
    end
end
