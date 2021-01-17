module Cedar
  class Output
    attr_reader :graphics

    def initialize
      @graphics = Cedar::Draw::Group.new
    end

    def reset
      @graphics.clear
    end
  end
end
