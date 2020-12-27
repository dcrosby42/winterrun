module Cedar
  class Resources
    def initialize
      @images = {}
      @fonts = {}
      @fonts[:default] = Gosu::Font.new(20)
    end

    def images(name)
      @images[name] ||= Gosu::Image.new("res/images/#{name}", tileable: true, retro: true)
    end

    def fonts(name)
      @fonts[name]
    end
  end
end
