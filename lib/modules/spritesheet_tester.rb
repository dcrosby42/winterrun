# require "cedar/ecs/systems/timer_system"
require "cedar/ecs"

class FixedTimeline
  def initialize(count:, fps: 60)
    @count = count
    @dur = 1.0 / fps
  end

  def frame_for(t)
    (t / @dur).floor % @count
  end

  def dur
    @count * @dur
  end
end

module SpritesheetTester
  extend self

  ZOrder = OpenStruct.new({
    BACKGROUND: 0,
    UNDERGRID: 1,
    SHEET: 5,
    UI: 10,
  })

  def new_state
    frame_rate = 24
    return open_struct({
             scale: 2,
             reload_timer: Cedar::Timer.new({ limit: 1.5, loop: true }),
             sheets: nil,
             selected_sheet: 0,
             selected_frame: 0,
             playing: false,
             frame_rate: frame_rate,
             frame_timer: Cedar::Timer.new({ limit: 1.0 / frame_rate, loop: true }),
           })
  end

  def load_resources(state, res)
    res.sprites.load("girl_sprite.json")
    res.sprites.load("boy_sprite.json")
  end

  def update(state, input, res)
    state.sheets ||= res.sprites.all.select do |s| s.instance_of?(Cedar::Resources::GridSpriteSheet) end
    state.scale = 1 if input.keyboard.pressed?(Gosu::KB_0)
    state.scale += 0.1 if input.keyboard.pressed?(Gosu::KB_EQUALS)
    state.scale -= 0.1 if input.keyboard.pressed?(Gosu::KB_MINUS)

    # Cycle sheet selection
    if input.keyboard.pressed?(Gosu::KB_RIGHT_BRACKET)
      state.selected_sheet = (state.selected_sheet + 1) % state.sheets.length
    elsif input.keyboard.pressed?(Gosu::KB_LEFT_BRACKET)
      state.selected_sheet = (state.selected_sheet - 1) % state.sheets.length
    end

    # Change anim speed
    if input.keyboard.pressed?(Gosu::KB_UP)
      amt = 1
      amt = 5 if input.keyboard.shift?
      state.frame_rate = [(state.frame_rate + amt), 60].min
      state.frame_timer.limit = 1.0 / state.frame_rate
    elsif input.keyboard.pressed?(Gosu::KB_DOWN)
      amt = 1
      amt = 5 if input.keyboard.shift?
      state.frame_rate = [(state.frame_rate - amt), 0].max
      state.frame_timer.limit = 1.0 / state.frame_rate
    end

    if input.keyboard.pressed?(Gosu::KB_SPACE)
      state.playing = !state.playing
    end

    # Cycle animation
    if state.playing
      Cedar.update_timer state.frame_timer, input.time.dt
      if state.frame_timer.alarm
        state.selected_frame = (state.selected_frame + 1) % state.sheets[state.selected_sheet].tile_grid.count
      end
    else
      if input.keyboard.pressed?(Gosu::KB_RIGHT)
        state.selected_frame = (state.selected_frame + 1) % state.sheets[state.selected_sheet].tile_grid.count
      elsif input.keyboard.pressed?(Gosu::KB_LEFT)
        state.selected_frame = (state.selected_frame - 1) % state.sheets[state.selected_sheet].tile_grid.count
      end
    end

    state
  end

  def draw(state, output, res)
    gs = Cedar::Draw::ScaleTransform.new(state.scale)

    frame = state.selected_frame
    sheet = state.sheets[state.selected_sheet]
    gs << Cedar::Draw::Image.new(
      image: sheet.image_for_frame(frame),
      x: 0,
      y: 36,
      z: ZOrder.SHEET,
    )

    draw_sheet_grid(0, 72, sheet, frame, gs, res)
    gs << Cedar::Draw::Image.new(
      path: sheet.path,
      x: 0,
      y: 72,
      z: ZOrder.SHEET,
    )

    output.graphics << gs

    text_y = 0
    label1 = Cedar::Draw::Label.new(text: "Sheet #{state.selected_sheet}: name: #{sheet.name} path: #{sheet.path} w=#{res.images[sheet.path].width} h=#{res.images[sheet.path].height}", y: text_y, z: ZOrder.UI)

    output.graphics << label1
    text_y += 20
    output.graphics << Cedar::Draw::Label.new(text: "fps: #{state.frame_rate} frame: #{state.selected_frame} of #{state.sheets[state.selected_sheet].tile_grid.count}", y: text_y, z: ZOrder.UI)
    # output.graphics << Cedar::Draw::Line.new(x1: 20, y1: 20, x2: 30, y2: 300)
  end

  UndergridColor1 = Gosu::Color.argb(255, 50, 100, 50)
  UndergridColor2 = Gosu::Color.argb(255, 50, 50, 100)
  HightlightColor = Gosu::Color.argb(50, 255, 255, 255)

  def draw_sheet_grid(offx, offy, sheet, n, outs, res)
    col = 0
    row = 0
    grid = sheet.tile_grid
    grid.count.times do |i|
      x = offx + grid.x + (grid.w * col)
      y = offy + grid.y + (grid.h * row)
      col += 1
      color = (row + col).even? ? UndergridColor1 : UndergridColor2
      outs << Cedar::Draw::Rect.new(x: x, y: y, z: ZOrder.UNDERGRID, w: grid.w, h: grid.h, color: color)
      if i == n
        outs << Cedar::Draw::Rect.new(x: x, y: y, z: ZOrder.UNDERGRID, w: grid.w, h: grid.h, color: HightlightColor)
      end
      if col >= grid.stride
        col = 0
        row += 1
      end
    end
  end
end
