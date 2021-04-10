module Cedar
  # Output is a structural abstraction around the graphical output context.
  # #window provides access to the Gosu::Window object for introspection purpises.
  # #graphics is the root Cedar::Draw::Group; drawing is accomplished by appending
  # parameterized drawing instructions to #graphics, eg:
  #     output.graphics << Draw::Rect.new(...)
  #     output.graphics << Draw::Label.new(...)
  class Output
    attr_reader :graphics, :window

    def initialize(window)
      @window = window
      @graphics = Cedar::Draw::Group.new
    end

    # Clears the root draw group.
    # Called by the framework just before each frame is drawn; user code
    # doesn't need to use this.
    def reset
      @graphics.clear
    end
  end
end
