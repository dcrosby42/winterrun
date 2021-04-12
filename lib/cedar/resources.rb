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
      raise "Can't find #{category} constructor for #{name.inspect}"
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
require "cedar/resources/base_sprite"
require "cedar/resources/image_sprite"
require "cedar/resources/grid_sheet_sprite"
require "cedar/resources/cyclic_sprite_animation"
