module Cedar

  # A Filter is anything that can be #call'd with with an Entity and returns true|false

  # NullFilter is nothing but an example.
  NullFilter = lambda do |entity| false end

  # CompTypeFilter is a Filter that matches an Entity that contains ALL the
  # expected component types.
  # (This is an extremely common case for entity matching.)
  # Construct with one of more component Classes or symbol names.
  class CompTypeFilter
    attr_reader :types

    def initialize(*types)
      @types = types.flatten.map do |t|
        case
        when t.respond_to?(:type)
          t.type
        else
          t.to_sym
        end
      end
    end

    def call(e)
      @types.all? { |t| e.has?(t) }
    end

    def inspect
      @types.inspect
    end
  end
end
