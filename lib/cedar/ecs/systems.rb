module Cedar

  # A system is anything that can be #call'd with (Cedar::EntityStore, Cedar::Input, Cedar::Resources).

  # NullSystem is nothing but an example.
  NullSystem = lambda do |estore, input, res|
  end

  # BaseSystem provides an INCOMPLETE basis for defining Systems (through inheritance)
  # based on a Search and assumed to iterate each resulting Entity in term
  # by invoking #update.
  # - Search must conform to the Search interface #call(Entity[]), see search.rb.
  # - Subclasses must implement #update(entity, input, res)
  class BaseSystem
    def initialize(search)
      @search = search
    end

    def call(estore, input, res)
      estore.search(@search).each do |e|
        update e, input, res
      end
    end

    def update(e, input, res)
      raise "#{self.class.name} needs to override #update(entity, input, res)"
    end

    def inspect
      "<#{self.class.name} #{@search.inspect}>"
    end
  end

  # BasicSystem implements the general System interface by applying a Search and invoking
  # the given update func for each Entity returned by the Search.
  # - search must conform to the Search interface #call(Entity[]), see search.rb.
  # - update must conform to #call(Entity, Cedar::Input, Cedar::Resources)
  class BasicSystem < BaseSystem
    def initialize(search, update)
      super search
      @update = update
    end

    def update(e, input, res)
      @update.call e, input, res
    end
  end

  # VERY common system pattern: A basic update system based on a component-type search.
  def self.define_system(*types, &update)
    search = EntityFilter.new(types.flatten)
    BasicSystem.new(search, update)
  end
end

require "cedar/ecs/systems/timer_system"
require "cedar/ecs/systems/sprite_anim_system"
