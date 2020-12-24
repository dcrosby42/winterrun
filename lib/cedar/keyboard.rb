class Cedar::Keyboard
  attr_reader :state
  attr_reader :keys_down, :keys_pressed, :keys_released

  def initialize
    @keys_down = {}
    @keys_pressed = {}
    @keys_released = {}
    @state = State.new(self)
  end

  def button_down(id)
    @keys_pressed[id] = true unless @keys_down[id]
    @keys_down[id] = true
  end

  def button_up(id)
    @keys_released[id] = true if @keys_down[id]
    @keys_down.delete(id)
  end

  def after_update
    @keys_pressed.clear
    @keys_released.clear
  end

  class State
    def initialize(keyboard)
      @k = keyboard
    end

    def down?(id)
      @k.keys_down[id] == true
    end

    def pressed?(id)
      @k.keys_pressed[id] == true
    end

    def shift?
      @k.keys_down[Gosu::KB_LEFT_SHIFT] || @k.keys_down[Gosu::KB_RIGHT_SHIFT]
    end

    def control?
      @k.keys_down[Gosu::KB_LEFT_CONTROL] || @k.keys_down[Gosu::KB_RIGHT_CONTROL]
    end

    def alt?
      @k.keys_down[Gosu::KB_LEFT_ALT] || @k.keys_down[Gosu::KB_RIGHT_ALT]
    end

    def meta?
      @k.keys_down[Gosu::KB_LEFT_META] || @k.keys_down[Gosu::KB_RIGHT_META]
    end

    def any?
      @k.keys_down.any? || @k.keys_released.any?
    end
  end
end
