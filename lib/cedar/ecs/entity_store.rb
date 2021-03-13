module Cedar
  class EntityStore
    def initialize
      @prev_eid = 0
      @ents = {}
      @cache = EntitySearchCache.new
    end

    def new_entity
      e = Entity.new(next_eid)
      e._listener = method(:notify)
      @ents[e.eid] = e
      yield e if block_given?
      e
    end

    def is_entity_id?(eid)
      Integer === eid && @ents.keys.include(eid)
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

    def notify(event_type, *params)
      @cache.notify(event_type, *params)
    end

    def update_cache
      @cache.update # resolve and clear notices, invalidating affected caches
    end

    def entities
      @ents.values.to_enum
    end

    def search(search = nil)
      if search
        @cache.register search
        if results = @cache.get(search)
          return results
        else
          results = search.call(entities)
          @cache.put(search, results)
          return results
        end
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

  class EntitySearchCache
    attr_accessor :logging_enabled

    def initialize
      @cache = {}
      @registered = {}
      # self.logging_enabled = true
      @events = {
        add_comp: Hash.new do |h, k| h[k] = [] end,
        remove_comp: Hash.new do |h, k| h[k] = [] end,
        add_remove_comp: Hash.new do |h, k| h[k] = [] end,
      }
      # !! add-or-remove(type)
      # add_entity(eid)
      # remove_entity(eid)
      # ? update_entity(eid)
      # ! add_component(eid, type)
      # ! remove_component(eid, type)
      # update_component(eid, type, attr, old_v, new_v)
    end

    def with_caching(search)
      if search.respond_to?(:cache_key) && search.respond_to?(:cache_invalid?)
        yield search.cache_key
      else
        nil
      end
    end

    def put(search, results)
      with_caching search do |key|
        log { "put[+]: #{results.length} entities -> #{key}" }
        @cache[key] = results
      end
    end

    def get(search)
      with_caching search do |key|
        results = @cache[key]
        if results.nil? or results.empty?
          log { "get[X]: #{key} MISS" }
          nil
        else
          log { "get[*]: #{key} <- #{results.length} entities" }
          results
        end
      end
    end

    def register(search)
      with_caching search do |key|
        unless @registered.include?(search.cache_key)
          log { "register search: #{search.cache_key}" }
          @registered[search.cache_key] = search
        end
      end
    end

    def unregister(search)
      with_caching search do |key|
        log { "unregister search: #{search.cache_key}" }
        @registered.delete(search.cache_key)
      end
    end

    def notify(event_type, *params)
      log { "notify: #{event_type}, #{params.inspect}" }
      case event_type
      when :add_comp
        comp = params[0]
        @events[:add_comp][comp.type] << comp
        @events[:add_remove_comp][comp.type] << comp
      when :remove_comp
        comp = params[0]
        @events[:remove_comp][comp.type] << comp
        @events[:add_remove_comp][comp.type] << comp
      end
      #TODO other types of events
    end

    def update
      # Resolve notices by invalidating caches that need it
      @registered.each do |key, search|
        handled = false
        with_caching search do |key|
          if search.cache_invalid?(@events)
            log { "resolve_notices: invalidating key #{key}" }
            @cache.delete key
          end
          handled = true
        end
        if not handled
          log { "resolve_notices: This search isn't cache-supporting; invalidating key #{key}. Why was it even registered? Bug? Search:#{search.inspect}" }
          @cache.delete key
        end
      end

      # Clear notices
      @events[:add_remove_comp].clear
      @events[:add_comp].clear
      @events[:remove_comp].clear
    end

    def log(msg = "")
      return unless logging_enabled
      msg += yield if block_given?
      puts "EntitySearchCache: #{msg}"
    end
  end
end
