require "keyboard"
require "mouse"
require "game_time"
require "sidefx"

class Game < Gosu::Window
  Input = Struct.new(:time, :keyboard, :mouse)

  def initialize(root_module:, caption: "Game", width: 1280, height: 720, fullscreen: false, update_interval: nil, mouse_pointer_visible: false)
    super width, height
    self.caption = caption
    @fullscreen = fullscreen
    self.fullscreen = @fullscreen
    self.update_interval = update_interval if update_interval
    @mouse_pointer_visible = false

    @keyboard = Keyboard.new
    @mouse = Mouse.new
    @time = GameTime.new

    @input = Input.new

    @module = root_module
    @state = @module.initialState(OpenStruct.new({ width: width, height: height }))
    @res = @module.initialResources
  end

  def start!
    puts "Starting #{self.caption}"
    show
  end

  def update
    @time.update_to Gosu.milliseconds

    @input.time = @time                # input.time #dt #dt_millis #millis
    @input.keyboard = @keyboard.state
    @input.mouse = @mouse

    s1, sidefx = @module.update(@state, @input, @res)
    @state = s1 unless s1.nil?
    @keyboard.after_update
    handle_sidefx sidefx
  end

  def handle_sidefx(sidefx)
    case sidefx
    when Array
      sidefx.each(&method(:handle_sidefx))
    when Sidefx::ToggleFullscreen
      @fullscreen = !@fullscreen
      puts "Toggle fullscreen => #{@fullscreen}"
      self.fullscreen = @fullscreen
    end
  end

  def draw
    @module.draw(@state, @res)
  end

  def button_down(id)
    @keyboard.button_down(id)
  end

  def button_up(id)
    @keyboard.button_up(id)
  end

  def needs_cursor?
    return @mouse_pointer_visible
  end

  # Unused (for now) Gosu callback
  # def needs_redraw?
  #   super
  # end

  # def drop
  #   super
  # end

  def close
    super
  end
end
