module RunLevel
  include Cedar
  extend Cedar::Helpers
end

require "cedar/ecs"
require "run_level/entities"
require "run_level/girl"
require "run_level/camera"
require "run_level/proto"

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
  Follower = Component.new(:follower, { target_name: nil, off_x: 0, off_y: 0 })

  _follower_search = CompSearch.new(Follower, Pos)
  _follow_target_search = CompSearch.new(FollowTarget, Pos)
  FollowerSystem = lambda do |estore, input, res|
    estore.search(_follower_search).each do |ef|
      want = ef.follower.target_name
      et = estore.search(_follow_target_search).find do |et| want == et.follow_target.name end
      ef.pos.x = et.pos.x - ef.follower.off_x
      ef.pos.y = et.pos.y - ef.follower.off_y
    end
  end

  def new_state
    estore = EntityStore.new
    initial_entities estore

    open_struct({
      estore: estore,
      grid_lines: {
        show: true,
        step_x: 100,
        step_y: 100,
      },
    })
  end

  # UpdateSystem = chain_systems(
  #   GirlSystem,
  #   AnimSystem,
  #   MotionSystem,
  #   CameraManualControlSystem,
  #   # FollowerSystem
  # )

  def update(state, input, res)
    # UpdateSystem.call(state.estore, input, res)
    [GirlSystem,
     AnimSystem,
     MotionSystem,
     CameraManualControlSystem,
     ParalaxSystem].each do |system|
      system.call state.estore, input, res
    end

    state.window_w = input.window.width
    state.window_h = input.window.height
    state
  end

  def draw(state, output, res)
    @cam_search ||= CompSearch.new(Camera, Pos)
    @sprite_search ||= CompSearch.new(Pos, Sprite)

    cam = state.estore.search(@cam_search).first
    if cam
      s = cam.camera.zoom
      output.graphics << Draw::Translate.new(-cam.pos.x * s, -cam.pos.y * s) do |tr|
        tr << Draw::Scale.new(s) do |g|
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

    #
    # Grid lines
    #
    if state.grid_lines.show
      (0..state.window_w).step(state.grid_lines.step_x).each do |x|
        output.graphics << Draw::Line.new(x1: x, y1: 0, x2: x, y2: state.window_h, z: 98)
        (0..state.window_h).step(state.grid_lines.step_y).each do |y|
          output.graphics << Draw::Line.new(x1: 0, y1: y, x2: state.window_w, y2: y, z: 98)
        end
      end
    end

    #
    # Debug text
    #
    msgs = get_debug_messages(state).to_a
    dbg_y = 0
    lh = 20
    z = 100
    w = output.window.width
    bgc = Gosu::Color.rgba(0, 0, 0, 80)
    msgs.each do |msg|
      output.graphics << Draw::Rect.new(x: 0, y: dbg_y, w: w, h: lh, z: z - 1, color: bgc)
      output.graphics << Draw::Label.new(text: msg, y: dbg_y, z: z)
      dbg_y += lh
    end
  end

  def dbg_fmt(val)
    case val
    when Float
      val.round(2)
    else
      val
    end
  end

  Debug_search = CompSearch.new(DebugWatch)

  def get_debug_messages(state)
    Enumerator.new do |y|
      y << "Window size: #{state.window_w}, #{state.window_h}"

      state.estore.search(Debug_search).each do |e|
        label = e.debug_watch.label
        e.debug_watch.watches.each do |cname, thing|
          comp = e.send(cname)
          if thing == true
            y << "#{label} #{comp.to_s}"
          elsif Symbol === thing
            y << "#{label} #{thing}: #{dbg_fmt comp.send(thing)}"
          elsif Array === thing
            str = thing.map do |prop|
              "#{prop}: #{dbg_fmt comp.send(prop)}"
            end.join(" ")
            y << "#{label} #{str}"
          end
        end
      end
    end
  end
end
