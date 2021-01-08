module Cedar
  class EntityStore
    def initialize
      @prev_eid = 0
      @ents = {}
    end

    def new_entity
      e = Entity.new(next_eid)
      @ents[e.eid] = e
      yield e if block_given?
      e
    end

    def destroy_entity
    end

    def each_entity(&block)
      @ents.values.each(&block)
    end

    private

    def next_eid
      @prev_eid += 1
    end
  end
end
