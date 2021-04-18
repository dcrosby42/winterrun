module RunLevel
  include Cedar
  extend Cedar::Helpers
end

require "cedar/ecs"
require "run_level/placeholder"
require "run_level/debug_watch"
require "run_level/camera"
require "run_level/follower"
require "run_level/background"
require "run_level/girl"
require "run_level/entities"

module RunLevel
  extend self

  def new_state
    estore = CachingEntityStore.new
    initial_entities estore

    open_struct({
      estore: estore,
      grid_lines: {
        show: false,
        step_x: 100,
        step_y: 100,
      },
      debug_console: {
        show: true,
      },
    })
  end

  $P = !!ENV["P"]

  def update(state, input, res)
    if input.keyboard.pressed?(Gosu::KB_P) and input.keyboard.shift?
      $P = true
    end
    if input.keyboard.pressed?(Gosu::KB_BACKTICK)
      state.debug_console.show = !state.debug_console.show
    end
    if input.keyboard.control? and input.keyboard.shift? and input.keyboard.pressed?(Gosu::KB_G)
      state.grid_lines.show = !state.grid_lines.show
    end

    # UpdateSystem.call(state.estore, input, res)
    [GirlSystem,
     MotionSystem,
     SpriteAnimSystem,
     CameraSystem,
     ParalaxBackgroundSystem].each do |system|
      system.call state.estore, input, res
    end

    state.window_w = input.window.width
    state.window_h = input.window.height
    state
  end

  def draw(state, output, res)
    @cam_search ||= EntityFilter.new(Camera, Pos)
    @sprite_search ||= EntityFilter.new(Pos, Sprite)

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
    if state.debug_console.show
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
  end

  def dbg_fmt(val)
    case val
    when Float
      val.round(2)
    else
      val
    end
  end

  def get_debug_messages(state)
    Enumerator.new do |y|
      y << "FPS: #{Gosu.fps}"
      y << "Window size: #{state.window_w}, #{state.window_h}"

      placeholder_entities(state.estore).each do |e|
        y << "#{e.placeholder.name}: #{dbg_fmt e.placeholder.data}"
      end
      state.estore.search(DebugWatch_filter).each do |e|
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
