module Cedar

  # A Search is anything that can be #call'd with an EntityStore and returns an Enumerable of Entity objects.

  # NullSearch is nothing but an example.
  NullSearch = lambda do |estore| [] end

  # FilterSearch is a Search that uses the given Filter to select Entity results from the estore.
  class FilterSearch
    def initialize(filter)
      @filter = filter
    end

    def call(estore)
      estore.each_entity.filter do |e| @filter.call(e) end
    end

    def inspect
      @filter.inspect
    end
  end

  # CompSearch is a convenient Search construct that converts the configured Component types
  # into a CompTypeFilter.
  # This is an extremely common Search case, the basis of many Systems.
  class CompSearch < FilterSearch
    def initialize(*types)
      super(CompTypeFilter.new(types))
    end
  end
end
