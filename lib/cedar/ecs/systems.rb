module Cedar

  # A system is anything that can be #call'd with (Cedar::EntityStore, Cedar::Input, Cedar::Resources).

  # NullSystem is nothing but an example.
  NullSystem = lambda do |estore, input, res|
  end

  # BasicSystem implements the general System interface by applying a Search and invoking
  # the given update func for each Entity returned by the Search.
  # - search must conform to the Search interface #call(Entity[]), see search.rb.
  # - update must conform to #call(Entity, Cedar::Input, Cedar::Resources)
  class BasicSystem
    def initialize(search, update)
      @search = search
      @update = update
    end

    def call(estore, input, res)
      estore.search(@search).each do |e|
        @update.call e, input, res
      end
    end

    def inspect
      "<BasicSystem #{@search.inspect}>"
    end
  end

  # VERY common system pattern: A basic update system based on a component-type search.
  def self.define_system(*types, &update)
    search = CompSearch.new(types.flatten)
    BasicSystem.new(search, update)
  end
end

require "cedar/ecs/systems/timer_system"
