module Cedar
  class Entity
    attr_reader :eid
    attr_accessor :_listener # callable that accepts an event. optional.

    def initialize(eid)
      @eid = eid
      @comps = {}
      @metaclass = class << self; self; end
    end

    def to_s
      "<Cedar::Entity eid=#{eid}>"
    end

    def add(comp)
      if respond_to?(comp.type)
        raise(ComponentError, "Entity[#{@eid}] already contains a Component of type #{comp.type.inspect}")
      end
      comp.eid = eid
      @metaclass.send :define_method, comp.type do comp end
      @comps[comp.type] = comp
      notify ComponentAddedEvent.new(comp)
      self
    end

    def remove(comp)
      if Symbol === comp
        if respond_to?(comp)
          send(comp).eid = nil
          @metaclass.send :remove_method, comp
          obj = @comps.delete comp
          notify ComponentDeletedEvent.new(obj)
        else
          raise(ComponentError, "Entity[#{@eid}] contains no Component of type #{comp.inspect}")
        end
      elsif comp.respond_to?(:type)
        remove comp.type
      else
        raise(ComponentError, "Entity[#{@eid}] can't remove unknown object #{comp.inspect}")
      end
    end

    # Remove ALL components
    def clear
      @comps.keys.each(&method(:remove))
    end

    def has?(type)
      @comps.include?(type)
    end

    def components
      @comps.values
    end

    def method_missing(name)
      @comps[name] || raise(ComponentError, "Entity[#{@eid}] contains no Component of type #{name.inspect}")
    end

    def inspect
      "<Entity-#{@eid}>"
    end

    def notify(evt)
      _listener.call(evt) if _listener
    end
  end
end
