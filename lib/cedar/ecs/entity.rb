module Cedar
  class Entity
    attr_reader :eid

    def initialize(eid)
      @eid = eid
      @comps = {}
      @metaclass = class << self; self; end
    end

    def add(comp)
      if respond_to?(comp.type)
        raise(ComponentError, "Entity[#{@eid}] already contains a Component of type #{comp.type.inspect}")
      end
      comp.eid = eid
      @metaclass.send :define_method, comp.type do comp end
      @comps[comp.type] = comp
    end

    def remove(comp)
      if Symbol === comp
        if respond_to?(comp)
          send(comp).eid = nil
          @metaclass.send :remove_method, comp
          @comps.delete comp
        else
          raise(ComponentError, "Entity[#{@eid}] contains no Component of type #{comp.inspect}")
        end
      elsif comp.respond_to?(:type)
        remove comp.type
      else
        raise(ComponentError, "Entity[#{@eid}] can't remove unknown object #{comp.inspect}")
      end
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
      "<Entity-#{@eid}>" #{@compse.keys.sort.inspect}"
    end
  end
end
