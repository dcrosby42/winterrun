module Cedar
  class EntityStore
    def initialize
      @prev_eid = 0
      @ents = {}
    end

    def new_entity
      e = _create_entity
      yield e if block_given?
      e
    end

    def _create_entity
      e = Entity.new(next_eid)
      @ents[e.eid] = e
    end

    def destroy_entity(e)
      if Integer === e
        e = @ents[e]
      end
      if e and e.respond_to?(:eid) && @ents.keys.include?(e.eid)
        e.clear
        @ents.delete e.eid
      end
    end

    def entities
      @ents.values.to_enum
    end

    def search(filter = nil)
      if filter
        entities.filter do |e| filter[e] end
      elsif block_given?
        entities.filter do |e| yield e end
      else
        entities
      end
    end

    private

    def next_eid
      @prev_eid += 1
    end
  end
end
