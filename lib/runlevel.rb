module RunLevel
  include Cedar
  extend Cedar::Helpers
end

require "cedar/ecs"
require "runlevel/entities"
require "runlevel/girl"
require "runlevel/camera"

module RunLevel
  extend self

  DebugWatch = Component.new(:debug_watch, { label: "watch", watches: nil })
  MotionSystem = define_system(Vel, Pos) do |e, input, res|
    e.pos.x += e.vel.dx * input.time.dt
    e.pos.y += e.vel.dy * input.time.dt
  end

  AnimSystem = define_system(Anim, Sprite) do |e, input, res|
    e.anim.t += (input.time.dt * e.anim.factor)
    anim = res.anims[e.anim.id]
    sprite_id, frame_id = anim.call(e.anim.t)
    e.sprite.id = sprite_id
    e.sprite.frame = frame_id
  end

  FollowTarget = Component.new(:follow_target, { name: nil })
  Follower = Component.new(:follower, { target_name: nil })

  _follower_search = CompSearch.new(Follower, Pos)
  _follow_target_search = CompSearch.new(FollowTarget, Pos)
  FollowerSystem = lambda do |estore, input, res|
    estore.search(_follower_search).each do |ef|
      want = ef.follower.target_name
      et = estore.search(_follow_target_search).find do |et| want == et.follow_target.name end
      ef.pos.x = et.pos.x - 20
      ef.pos.y = et.pos.y - 20
    end
  end

  def new_state
    estore = EntityStore.new
    initial_entities estore

    open_struct({
      estore: estore,
      debugs: [],
    })
  end

  UpdateSystem = chain_systems(
    GirlSystem,
    AnimSystem,
    MotionSystem,
    CameraManualControlSystem,
    # FollowerSystem
  )

  def update(state, input, res)
    state.debugs.clear
    state.debugs << "DUder"
    UpdateSystem.call(state.estore, input, res)
    state
  end

  Debug_watch_search = CompSearch.new(DebugWatch)

  def draw(state, output, res)
    @cam_search ||= CompSearch.new(Camera, Pos)
    @sprite_search ||= CompSearch.new(Pos, Sprite)

    cam = state.estore.search(@cam_search).first
    if cam
      output.graphics << Draw::Translate.new(-cam.pos.x, -cam.pos.y) do |tr|
        tr << Draw::Scale.new(cam.camera.zoom) do |g|
          state.estore.search(@sprite_search).each do |e|
            g << Draw::SheetSprite.new(
              sprite_id: e.sprite.id,
              sprite_frame: e.sprite.frame,
              x: e.pos.x,
              y: e.pos.y,
              z: e.pos.z,
              scale_x: e.sprite.scale_x,
              scale_y: e.sprite.scale_y,
              center_x: e.sprite.center_x,
              center_y: e.sprite.center_y,
            )
          end
        end
      end
    end

    output.graphics << Draw::Rect.new(x: 0, y: 500, z: 100, w: 100, h: 100)

    msgs = []
    msgs.concat(state.debugs)
    state.estore.search(Debug_watch_search).each do |e|
      label = e.debug_watch.label
      e.debug_watch.watches.each do |cname, thing|
        comp = e.send(cname)
        if thing == true
          msgs << "#{label} #{comp.to_s}"
        elsif Symbol === thing
          msgs << "#{label} #{thing}: #{comp.send(thing)}"
        elsif Array === thing
          str = thing.map do |prop|
            "#{prop}: #{comp.send(prop)}"
          end.join(" ")
          msgs << "#{label} #{str}"
        end
      end
    end

    dbg_y = 0
    lh = 20
    msgs.each do |msg|
      output.graphics << Draw::Label.new(text: msg, y: dbg_y, z: 100)
      dbg_y += lh
    end
  end
end
