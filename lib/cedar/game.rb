class Cedar::Game < Gosu::Window
  def initialize(root_module:, caption: "Game", width: 1280, height: 720, fullscreen: false, update_interval: nil, mouse_pointer_visible: false, reload_button: Gosu::KB_R)
    super width, height
    self.caption = caption
    @fullscreen = fullscreen
    self.fullscreen = @fullscreen
    self.update_interval = update_interval if update_interval
    @mouse_pointer_visible = false
    @reload_button = reload_button

    @input = Cedar::Input.new
    @output = Cedar::Output.new(self)

    @module = root_module
    reset_state
  end

  def reset_state
    @state = @module.new_state
    @res = new_resources
    @module.load_resources(@state, @res) if @module.respond_to?(:load_resources)
  end

  def new_resources
    resource_loader = Cedar::Resources::ResourceLoader.new(dir: "res")
    res = Cedar::Resources.new(resource_loader: resource_loader)
    [
      Cedar::Resources::ImageSprite,
      Cedar::Resources::GridSheetSprite,
      Cedar::Resources::CyclicSpriteAnimation,
    ].each do |c|
      res.register_object_type c
    end
    res
  end

  def start!
    puts "Starting #{self.caption}"
    show
  end

  def update
    did_reload = check_for_reload
    # did_reset = check_for_reset
    @input.time.update_to Gosu.milliseconds

    @input.window = self
    @input.did_reload = did_reload
    @input.did_reset = false

    s1, sidefx = @module.update(@state, @input, @res)
    @state = s1 unless s1.nil?
    @input.keyboard.after_update
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
    @output.reset
    @module.draw(@state, @output, @res)
    @output.graphics.draw(@res)
  end

  def button_down(id)
    @input.keyboard.button_down(id)
  end

  def button_up(id)
    @input.keyboard.button_up(id)
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
    if @input.keyboard.alt? and @input.keyboard.pressed?(@reload_button)
      return reload_code
    end
    false
  end

  # def check_for_reset
  #   if @input.keyboard.shift? and @input.keyboard.pressed?(@reload_button)
  #     reset_state
  #     puts "State reset"
  #     true
  #   end
  #   false
  # end
end
