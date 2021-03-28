module Cedar
  class CachingEntityStore < EntityStore
    def initialize
      super
      @cache = Cache.new
    end

    def new_entity
      e = _create_entity
      e._listener = @cache.method(:handle_event)
      yield e if block_given?
      e
    end

    def search(filter = nil)
      if filter
        @cache.get(entities, filter)
      else
        super
      end
    end

    class Cache
      def initialize
        @data = {}
      end

      def get(entities, filter)
        return @data[filter] if @data.include?(filter)
        @data[filter] = entities.select do |e| filter.call(e) end
      end

      def handle_event(evt)
        @data.keys.each do |filter|
          # evict cached data for affected filters:
          @data.delete(filter) if filter.affected_by_event?(evt)
        end
      end
    end
  end
end
