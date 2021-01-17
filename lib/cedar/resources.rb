module Cedar
  class Resources
    attr_reader :sprites, :anims, :images, :fonts, :files #, :data

    def initialize(dir: nil)
      @dir = dir || "res"

      @images = Images.new(self)
      @files = Files.new(self)
      @fonts = {}
      @fonts[:default] = Gosu::Font.new(20)
      @sprites = Sprites.new(self)
      @anims = {}
      # @data = OpenStruct.new
    end

    def path(name)
      if !File.exist?(name)
        name = "#{@dir}/#{name}"
      end
      if !File.exist?(name)
        raise "Resources path: cannot find file '#{name.inspect}'"
      end
      name
    end

    class Files
      def initialize(res)
        @res = res
        @parsed_files = {}
      end

      def get(name)
        @parsed_files[name] ||= begin
            name = @res.path("files/#{name}")
            load_and_parse(name)
          end
      end

      alias_method :[], :get
      alias_method :call, :get

      private

      def load_and_parse(name)
        name = @res.path(name)
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

    class Images
      def initialize(res)
        @images = {}
        @res = res
      end

      def get(name)
        raise("Can't get image #{name.inspect}") if name.nil? || name.length == 0
        name = @res.path("images/#{name}")
        @images[name] ||= Gosu::Image.new(name, tileable: true, retro: true)
      end

      alias_method :[], :get
      alias_method :call, :get
    end

    class Sprites
      def initialize(res)
        @res = res
        @sheets = {}
      end

      def all
        @sheets.values
      end

      def get(name)
        s = @sheets[name]
        if s.nil?
          raise("No Sprite '#{name.inspect}'")
        end
        s
      end

      alias_method :[], :get
      alias_method :call, :get

      # Install a Sprite from file, object, array of objs, etc.
      def load(arg)
        case arg
        when String
          load_file(arg) # always returns list even if just 1 entry in the file
        when Hash
          [load_sheet(arg)] # return as a list
        when Array
          arg.map(&method(:load)) # return the list of sprites
        else
          raise("Sprites#load: cannot process #{arg.inpsect}")
        end
      end

      private

      # Install sprites from a (presumably json or yaml) file of 1 or more sprite sheet definitions
      def load_file(file)
        sheet_infos = @res.files[file]
        sheet_infos = [sheet_infos] unless Array === sheet_infos
        sheet_infos.map(&method(:load_sheet)) # return the list of sprites
      end

      # Install a sprite from the given "sheet info" which may be one of several types.
      def load_sheet(sheet_info)
        sheet = case sprite_type_of(sheet_info)
          when :grid_sprite_sheet
            GridSpriteSheet.new(res: @res, **sheet_info) # :path, :name, :tile_grid
          when :image_sprite
            ImageSprite.new(res: @res, **sheet_info) # :name, :path|:paths
          else
            raise "Unknown sheet :type"
          end

        if Cedar.mode == :prod
          if @sheets[sheet.name]
            raise "Duplicate SpriteSheet id #{sheet.name.inspect} from file #{file.inspect}"
          end
          puts "Sprites#load: file=#{file} sheet=#{sheet.name}"
        end

        @sheets[sheet.name] = sheet
        sheet
      rescue => e
        raise("Error loading sheet_info #{sheet_info.inspect}: #{e}\n#{e.backtrace.join("\n\t")}")
      end

      def sprite_type_of(sheet_info)
        (sheet_info && sheet_info[:type] && sheet_info[:type].to_sym) || raise("Dunno type of sheet_info: #{sheet_info.inspect}")
      end
    end

    # A Sprite implementation based on a sprite sheet definition.
    # Sprite sheet {:name, :path, tile_grid:{:x,:y,:w,:h,:count,:stride}}
    class GridSpriteSheet
      attr_reader :path, :name, :tile_grid

      def initialize(res:, path:, name:, type:, tile_grid:)
        @res = res
        @path = path
        @name = name
        @tile_grid = open_struct(tile_grid) # x y w h count stride
        @subs = []
      end

      def frame_count
        @tile_grid.count
      end

      def image_for_frame(i)
        i = i % frame_count
        @subs[i] ||= begin
            left = @tile_grid.x + @tile_grid.w * (i % @tile_grid.stride)
            top = @tile_grid.y + @tile_grid.h * (i / @tile_grid.stride)
            img = @res.images[@path]
            img.subimage(left, top, @tile_grid.w, @tile_grid.h)
          end
      end
    end

    # A Sprite implementation based simply on one or more full images.
    class ImageSprite
      attr_reader :name, :paths

      def initialize(res:, name:, type:, path: nil, paths: nil)
        @res = res
        @name = name
        @paths = if paths
            paths
          else
            if path
              [path]
            end
          end
        raise(":path or :paths required") if !@paths
      end

      def frame_count
        @paths.length
      end

      def image_for_frame(i)
        @res.images[@paths[i % frame_count]]
      end
    end
  end
end
