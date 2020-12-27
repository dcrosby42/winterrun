module Cedar
  class Resources
    attr_reader :data

    def initialize
      @images = {}
      @files = {}
      @fonts = {}
      @fonts[:default] = Gosu::Font.new(20)
      @data = OpenStruct.new
    end

    def images(name)
      @images[name] ||= Gosu::Image.new("res/images/#{name}", tileable: true, retro: true)
    end

    def fonts(name)
      @fonts[name]
    end

    def files(name)
      @files[name] ||= load_and_parse("res/files/#{name}")
    end

    private

    def load_and_parse(name)
      case File.extname(name)
      when ".json"
        require "json"
        JSON.parse(File.read(name), symbolize_names: true)
      when ".yaml", ".yml"
        require "yaml"
        YAML.load(File.read(name))
      else
        File.read(name)
      end
    end
  end
end
