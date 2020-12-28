module Cedar
  class Resources
    attr_reader :data, :fonts, :images, :sprites, :files

    def initialize
      @images = Images.new
      @files = {}
      @fonts = {}
      @fonts[:default] = Gosu::Font.new(20)
      @data = OpenStruct.new
      @sprites = Sprites.new
    end

    class << self
      def load_and_parse(name)
        if !File.exist?(name)
          name = "res/#{name}"
        end
        if !File.exist?(name)
          raise "Resources.load_and_parse: cannot find file '#{name.inspect}'"
        end

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

    class Files
      def initialize
        @files = {}
      end

      def get(name)
        @files[name] ||= self.class.load_and_parse("res/files/#{name}")
      end

      def [](name)
        get name
      end
    end

    class Images
      def initialize
        @images = {}
      end

      def get(name)
        @images[name] ||= Gosu::Image.new("res/images/#{name}", tileable: true, retro: true)
      end

      def [](name)
        get name
      end
    end

    class Sprites
      def initialize
        @sheets = {}
      end

      def get(id)
        s = @sheets[id]
        if s.nil?
          raise("No Sprite '#{id.inspect}'")
        end
        s
      end

      def [](id)
        get id
      end

      def load(file)
        data = Resources.load_and_parse(file)
        data = [data] unless Array === data
        data.each do |sheet_info|
          sheet = SpriteSheet.new(**sheet_info) # :path, :name, :tile_grid
          if @sheets[sheet.name]
            raise "Duplicate SpriteSheet id #{sheet.name.inspect} from file #{file.inspect}"
          end
          @sheets[sheet.name] = sheet
        end
      end
    end

    class SpriteSheet
      attr_reader :path, :name, :tile_grid

      def initialize(path:, name:, tile_grid:)
        @path = path
        @name = name
        @tile_grid = open_struct(tile_grid) # x y w h count stride
      end

      def frame_count
        @tile_grid.count
      end

      def image_for_frame(i, res)
        i = i % frame_count
        left = @tile_grid.x + @tile_grid.w * (i % @tile_grid.stride)
        top = @tile_grid.y + @tile_grid.h * (i / @tile_grid.stride)
        img = res.images[@path]
        return img.subimage(left, top, @tile_grid.w, @tile_grid.h)
      end
    end
  end
end
