module Cedar
  class Resources
    def initialize(resource_loader:)
      @resource_loader = resource_loader
      @types = {}
      @caches = Hash.new do |h, k| h[k] = {} end
      @configs = Hash.new do |h, k| h[k] = {} end
      @ctors = Hash.new do |h, k| h[k] = {} end
      @dynamic_ctors = {
        image: lambda do |name| lambda do @resource_loader.load_image(name) end end,
        file: lambda do |name| lambda do @resource_loader.load_file(name) end end,
        data: lambda do |name| lambda do @resource_loader.load_data(name) end end,
      }
    end

    def register_object_type(obj_type)
      type_name = if obj_type.respond_to?(:type)
          obj_type.type
        elsif Class === obj_type
          obj_type.name.split("::").last.underscore
        else
          raise("Dunno how to get 'type' string of obj_type=#{obj_type.inspect}")
        end
      @types[type_name] = obj_type
    end

    def find_object_type(obj_config)
      @types[obj_config[:type].to_s.underscore] || raise("Can't determine type of resource object to use for #{obj_config.inspect}")
    end

    # Register one or more object configurations.
    # All object config Hashes must have :name and :type keys. (Keys may be strings or symbols)
    # When given an Array, each item of the Array will be re-sent to #configure.
    # When given a String, it's assumed to be a data file, which is loaded and sent to #configure.
    def configure(obj_conf)
      case obj_conf
      when Hash
        obj_conf = obj_conf.with_indifferent_access
        # create a deferred instantiator for this object:
        obj_type = find_object_type(obj_conf)
        constructor = Constructor.new(self, obj_type, obj_conf)
        cat = obj_type.category
        @ctors[cat][obj_conf[:name]] = constructor
      when String
        configure get_data(obj_conf)
      when Array
        obj_conf.each do |c| configure c end
      end
    end

    def get_image(name)
      get_resource :image, name
    end

    def get_file(name)
      get_resource :file, name
    end

    def get_data(name)
      get_resource :data, name
    end

    def get_sprite(name)
      get_resource :sprite, name
    end

    def get_animation(name)
      get_resource :animation, name
    end

    def get_resource(category, name)
      @caches[category][name] ||= get_constructor(category, name).call
    end

    private

    def get_constructor(category, name)
      ctor = @ctors[category][name]
      return ctor if ctor

      dctor = @dynamic_ctors[category]
      if dctor
        return dctor.call(name)
      end
      raise "Can't find resource constructor for category=#{category} name=#{name.inspect}"
    end

    # A Constructor bundles an object type and config (and a references to the Resources facade)
    # for deferred instantiation of resource objects such as sprites and animations.
    Constructor = Struct.new(:resources, :obj_type, :obj_config) do
      def call
        obj_type.construct(resources: resources, config: obj_config)
      end
    end
  end
end

require "cedar/resources/resource_loader"
require "cedar/resources/grid_sprite_sheet"
require "cedar/resources/cyclic_sprite_animation"

#   attr_reader :sprites, :anims, :images, :fonts, :files #, :data

#   def initialize(dir: "res")
#     @images = Images.new(self)
#     @files = Files.new(self)
#     @fonts = {}
#     @fonts[:default] = Gosu::Font.new(20)
#     @sprites = Sprites.new(self)
#     @anims = {}
#     # @data = OpenStruct.new
#   end

#   def path(name)
#     if !File.exist?(name)
#       name = "#{@dir}/#{name}"
#     end
#     if !File.exist?(name)
#       raise "Resources path: cannot find file '#{name.inspect}'"
#     end
#     name
#   end

#   def load(arg)
#     case arg
#     when String
#       data = self.files[arg]
#       data = [data] unless Array === data
#       data.map(&method(:load_object)) # return the list of sprites
#     when Hash
#       [load_object(arg)] # return as a list
#     when Array
#       arg.map(&method(:load)) # return the list of objects
#     else
#       raise("Resources#load: cannot process #{arg.inpsect}")
#     end
#   end

#   def load_object(h)
#     klass, collname = ClassMap[data_type_of(h)]
#     obj = if klass
#         klass.new(res: @res, **h)
#       else
#         raise "Unknown object type #{data_type_of(h)}"
#       end

#     coll = self.send(collname.to_sym)
#     if Cedar.mode == :prod
#       if coll[obj.name]
#         raise "Duplicate SpriteSheet id #{sheet.name.inspect} from file #{file.inspect}"
#       end
#     end

#     coll[obj.name] = obj
#     obj
#   end

#   class Files
#     def initialize(res)
#       @res = res
#       @parsed_files = {}
#     end

#     def get(name)
#       @parsed_files[name] ||= begin
#           name = @res.path("files/#{name}")
#           load_and_parse(name)
#         end
#     end

#     alias_method :[], :get
#     alias_method :call, :get

#     private

#     def load_and_parse(name)
#       name = @res.path(name)
#       case File.extname(name)
#       when ".json"
#         require "json"
#         JSON.parse(File.read(name), symbolize_names: true)
#       when ".yaml", ".yml"
#         require "yaml"
#         YAML.load(File.read(name))
#       else
#         File.read(name)
#       end
#     end
#   end

#   class Images
#     def initialize(res)
#       @images = {}
#       @res = res
#     end

#     def get(name)
#       @images[name] ||= begin
#           raise("Can't get image #{name.inspect}") if name.nil? || name.length == 0
#           iname = @res.path("images/#{name}")
#           img = Gosu::Image.new(iname, tileable: true, retro: true)
#           img
#         end
#     end

#     alias_method :[], :get
#     alias_method :call, :get
#   end

#   class NamedColl
#     def initialize(name)
#       @h = {}
#     end

#     def all
#       @h.values
#     end

#     def get(key)
#       @h[key]
#     end
#   end

#   class Sprites
#     def initialize(res)
#       @res = res
#       @sheets = {}
#     end

#     def all
#       @sheets.values
#     end

#     alias_method :[], :get
#     alias_method :call, :get

#     def get(name)
#       s = @sheets[name]
#       if s.nil?
#         raise("No Sprite '#{name.inspect}'")
#       end
#       s
#     end

#     alias_method :[], :get
#     alias_method :call, :get

#     # Install a Sprite from file, object, array of objs, etc.
#     def load(arg)
#       case arg
#       when String
#         load_file(arg) # always returns list even if just 1 entry in the file
#       when Hash
#         [load_sheet(arg)] # return as a list
#       when Array
#         arg.map(&method(:load)) # return the list of sprites
#       else
#         raise("Sprites#load: cannot process #{arg.inpsect}")
#       end
#     end

#     private

#     # Install sprites from a (presumably json or yaml) file of 1 or more sprite sheet definitions
#     def load_file(file)
#       sheet_infos = @res.files[file]
#       sheet_infos = [sheet_infos] unless Array === sheet_infos
#       sheet_infos.map(&method(:load_sheet)) # return the list of sprites
#     end

#     # Install a sprite from the given "sheet info" which may be one of several types.
#     def load_sheet(sheet_info)
#       sheet = case sprite_type_of(sheet_info)
#         when :grid_sprite_sheet
#           GridSpriteSheet.new(res: @res, **sheet_info) # :path, :name, :tile_grid
#         when :image_sprite
#           ImageSprite.new(res: @res, **sheet_info) # :name, :path|:paths
#         else
#           raise "Unknown sheet :type"
#         end

#       if Cedar.mode == :prod
#         if @sheets[sheet.name]
#           raise "Duplicate SpriteSheet id #{sheet.name.inspect} from file #{file.inspect}"
#         end
#       end

#       @sheets[sheet.name] = sheet
#       sheet
#     rescue => e
#       raise("Error loading sheet_info #{sheet_info.inspect}: #{e}\n#{e.backtrace.join("\n\t")}")
#     end

#     def sprite_type_of(sheet_info)
#       (sheet_info && sheet_info[:type] && sheet_info[:type].to_sym) || raise("Dunno type of sheet_info: #{sheet_info.inspect}")
#     end
#   end

#   # A Sprite implementation based on a sprite sheet definition.
#   # Sprite sheet {:name, :path, tile_grid:{:x,:y,:w,:h,:count,:stride}}
#   class GridSpriteSheet
#     attr_reader :path, :name, :tile_grid, :center_x, :center_y

#     def initialize(res:, path:, name:, type:, tile_grid:)
#       @res = res
#       @path = path
#       @name = name
#       @tile_grid = open_struct(tile_grid) # x y w h count stride
#       @subs = []
#     end

#     def frame_count
#       @tile_grid.count
#     end

#     def image_for_frame(i)
#       i = i % frame_count
#       @subs[i] ||= begin
#           left = @tile_grid.x + @tile_grid.w * (i % @tile_grid.stride)
#           top = @tile_grid.y + @tile_grid.h * (i / @tile_grid.stride)
#           img = @res.images[@path]
#           img.subimage(left, top, @tile_grid.w, @tile_grid.h)
#         end
#     end
#   end
# end

# # A Sprite implementation based simply on one or more full images.
# class ImageSprite
#   attr_reader :name, :paths, :center_x, :center_y

#   def initialize(res:, name:, type:, path: nil, paths: nil)
#     @res = res
#     @name = name
#     @paths = if paths
#         paths
#       else
#         if path
#           [path]
#         end
#       end
#     raise(":path or :paths required") if !@paths
#   end

#   def frame_count
#     @paths.length
#   end

#   def image_for_frame(i)
#     @res.images[@paths[i % frame_count]]
#   end
# end

# class CircularSpriteAnimation
#   attr_reader :type, :name

#   def initialize(res:, type:, path:, name:)
#     @name = name
#     @type = type.to_sym
#   end
# end

# # A Sprite implementation based on a sprite sheet definition.
# # Sprite sheet {:name, :path, tile_grid:{:x,:y,:w,:h,:count,:stride}}
# class GridSpriteSheet
#   attr_reader :path, :name, :tile_grid, :center_x, :center_y

#   def initialize(res:, path:, name:, type:, tile_grid:)
#     @res = res
#     @path = path
#     @name = name
#     @tile_grid = open_struct(tile_grid) # x y w h count stride
#     @subs = []
#   end

#   def frame_count
#     @tile_grid.count
#   end

#   def image_for_frame(i)
#     i = i % frame_count
#     @subs[i] ||= begin
#         left = @tile_grid.x + @tile_grid.w * (i % @tile_grid.stride)
#         top = @tile_grid.y + @tile_grid.h * (i / @tile_grid.stride)
#         img = @res.images[@path]
#         img.subimage(left, top, @tile_grid.w, @tile_grid.h)
#       end
#   end
# end

# ClassMap = {
#   grid_sprite_sheet: [GridSpriteSheet, :sprites],
#   image_sprite: [ImageSprite, :sprites],
#   circular_sprite_animation: [CircularSpriteAnimation, :anims],
# }
# end
