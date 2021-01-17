module Cedar
  class Input
    attr_accessor :time, :keyboard, :mouse, :window, :did_reload, :did_reset

    def initialize
      @time = GameTime.new
      @keyboard = Keyboard.new
      @mouse = Mouse.new
    end
  end
end

# Cedar::Input = Struct.new(
#   :time,       # Cedar::GameTime
#   :keyboard,   # Cedar::Keyboard
#   :mouse,      # Cedar::Mouse
#   :window,     # Gosu::Window
#   :did_reload, # bool
#   :did_reset # bool
# )
