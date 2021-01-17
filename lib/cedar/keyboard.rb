class Cedar::Keyboard
  attr_reader :state
  attr_reader :keys_down, :keys_pressed, :keys_released

  def initialize
    @keys_down = {}
    @keys_pressed = {}
    @keys_released = {}
  end

  def button_down(id)
    @keys_pressed[id] = true unless @keys_down[id]
    @keys_down[id] = true
  end

  def button_up(id)
    @keys_released[id] = true if @keys_down[id]
    @keys_down.delete(id)
  end

  # Clears "pressed" and "released" states, as those are ephemeral (meant to last only for 1 tick)
  def after_update
    @keys_pressed.clear
    @keys_released.clear
  end

  # Resets ALL button state
  def clear
    @keys_pressed.clear
    @keys_released.clear
    @keys_down.cleae
  end

  # QUERIES:

  def down?(id)
    keys_down[id] == true
  end

  def pressed?(id)
    keys_pressed[id] == true
  end

  def released?(id)
    keys_released[id] == true
  end

  def shift?
    keys_down[Gosu::KB_LEFT_SHIFT] || keys_down[Gosu::KB_RIGHT_SHIFT]
  end

  def control?
    keys_down[Gosu::KB_LEFT_CONTROL] || keys_down[Gosu::KB_RIGHT_CONTROL]
  end

  def alt?
    keys_down[Gosu::KB_LEFT_ALT] || keys_down[Gosu::KB_RIGHT_ALT]
  end

  def meta?
    keys_down[Gosu::KB_LEFT_META] || keys_down[Gosu::KB_RIGHT_META]
  end

  def any?
    keys_down.any? || @k.keys_released.any?
  end
end
