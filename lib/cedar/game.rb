Cedar::Input = Struct.new(:time, :keyboard, :mouse, :did_reload, :did_reset)

class Cedar::Game < Gosu::Window
  def initialize(root_module:, caption: "Game", width: 1280, height: 720, fullscreen: false, update_interval: nil, mouse_pointer_visible: false, reload_button: Gosu::KB_R)
    super width, height
    self.caption = caption
    @fullscreen = fullscreen
    self.fullscreen = @fullscreen
    self.update_interval = update_interval if update_interval
    @mouse_pointer_visible = false
    @reload_button = reload_button

    @keyboard = Cedar::Keyboard.new
    @mouse = Cedar::Mouse.new
    @time = Cedar::GameTime.new
    @input = Cedar::Input.new

    @module = root_module
    reset_state
  end

  def reset_state
    @state = @module.initialState(OpenStruct.new({ width: self.width, height: self.height }))
    @res = @module.initialResources
  end

  def start!
    puts "Starting #{self.caption}"
    show
  end

  def update
    did_reload = check_for_reload
    did_reset = check_for_reset
    @time.update_to Gosu.milliseconds

    @input.time = @time                # input.time #dt #dt_millis #millis
    @input.keyboard = @keyboard.state
    @input.mouse = @mouse
    @input.did_reload = did_reload
    @input.did_reset = did_reset

    s1, sidefx = @module.update(@state, @input, @res)
    @state = s1 unless s1.nil?
    @keyboard.after_update
    handle_sidefx sidefx
  end

  def handle_sidefx(sidefx)
    case sidefx
    when Array
      sidefx.each(&method(:handle_sidefx))
    when Cedar::Sidefx::ToggleFullscreen
      @fullscreen = !@fullscreen
      puts "Toggle fullscreen => #{@fullscreen}"
      self.fullscreen = @fullscreen
    when Cedar::Sidefx::Reload
      reload_code
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

  def reload_code
    if AutoReload.reload_all
      puts "Code reloaded"
      return true
    end
    false
  end

  def check_for_reload
    if @keyboard.state.alt? and @keyboard.state.pressed?(@reload_button)
      return reload_code
    end
    false
  end

  def check_for_reset
    if @keyboard.state.shift? and @keyboard.state.pressed?(@reload_button)
      reset_state
      puts "State reset"
      true
    end
    false
  end
end