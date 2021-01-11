module Cedar

  # A Search is a callable object that accepts an enumerable of Entities,
  # filters them down, and returns an enumerable of result Entities.

  # NullSearch is nothing but an example.
  NullSearch = lambda do |entities| [] end

  # FilterSearch is a Search that uses the given Filter to select Entity results from the estore.
  class FilterSearch
    def initialize(filter)
      @filter = filter
    end

    def call(entities)
      entities.filter do |e| @filter.call(e) end
    end

    def inspect
      @filter.inspect
    end
  end

  # CompSearch is a convenient Search construct that converts the configured Component types
  # into a CompTypeFilter.
  # This is an extremely common Search case, the basis of many Systems.
  #
  # CACHING: CompSearch implements an optional "secret interface" to support EntityStore result caching:
  #   cache_key
  #   cache_invalid?(events)
  class CompSearch < FilterSearch
    attr_reader :cache_key

    def initialize(*types)
      filter = CompTypeFilter.new(types)
      super filter
      @types = filter.types
      @cache_key = "CompSearch-#{@types.map(&:to_s).join("-")}"
    end

    def cache_invalid?(events)
      @types.any? do |type| events[:add_remove_comp][type].length > 0 end
    end
  end

  class CompSearch_NonCaching < FilterSearch
    def initialize(*types)
      filter = CompTypeFilter.new(types)
      super filter
      @types = filter.types
    end
  end
end
