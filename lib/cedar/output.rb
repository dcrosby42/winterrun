module Cedar
  class Output
    attr_reader :graphics, :window

    def initialize(window)
      @window = window
      @graphics = Cedar::Draw::Group.new
    end

    def reset
      @graphics.clear
    end
  end
end
