module Cedar

  # A system is anything that can be #call'd with (Cedar::EntityStore, Cedar::Input, Cedar::Resources).

  # NullSystem is nothing but an example.
  NullSystem = lambda do |estore, input, res|
  end

  # BasicSystem implements the general System interface by applying a Search and invoking
  # the given update func for each Entity returned by the Search.
  class BasicSystem
    def initialize(search, update)
      @search = search
      @update = update
    end

    def call(estore, input, res)
      @search.call(estore).each do |e|
        @update.call e, input, res
      end
    end

    def inspect
      "<BasicSystem #{@search.inspect}>"
    end
  end
end

require "cedar/ecs/systems/timer_system"
