module Cedar
  class ComponentError < StandardError; end

  module ComponentFactory
    CommonProps = {
      eid: nil,
    }

    def new(comp_type, pdefs)
      @comp_types ||= {}
      comp_type = comp_type.to_sym
      prop_defs = CommonProps.clone.merge(pdefs.clone)
      comp_class = Class.new(Struct.new(*prop_defs.keys)) do
        def defaults!(h = {})
          ps = self.class.props
          incoming = h.keys
          incoming.delete(:type)
          incoming.each do |k|
            raise "Can't assign property #{k.inspect} for Component<#{type.inspect}, #{ps.keys.inspect}>" unless ps.include?(k)
          end
          ps.each do |name, default|
            val = h.include?(name) ? h[name] : default
            self.send("#{name}=", val)
          end
          self
        end

        def to_h
          h = super
          h[:type] = type
          h
        end
      end

      comp_class.define_singleton_method(:props) do
        prop_defs
      end

      _new = comp_class.method(:new)

      comp_class.define_singleton_method(:new) do |h = {}|
        obj = _new.call
        obj.defaults!(h)
      end

      comp_class.define_method(:type) do comp_type end

      comp_class.define_singleton_method(:type) do comp_type end

      @comp_types[comp_type] = comp_class

      comp_class
    end

    def from_h(h)
      raise("from_h: must be called with a Hash") unless Hash === h
      raise("from_h: Hash must have :type or 'type' key") unless h.include?(:type) || h.include?("type")
      type = (h[:type] || h["type"]).to_sym
      @comp_types ||= {}
      raise("from_h: No Component registered for type #{type.inspect}") unless @comp_types.include?(type)
      comp_class = @comp_types[type]
      comp_class.new(h)
    end
  end

  #
  #   Timer = Component.new(:timer, { t: 0, limit: 2, alarm: false })
  #   timer = Timer.new({limit: 0.1})
  #   timer.limit  # => 0.1
  #   timer.to_h  # => {:t=>0.3, :limit=>0.3, :alarm=>true, :type=>:timer}
  #   copied_timer = Component.from_h(timer.to_h)
  class Component
    extend ComponentFactory
  end

  ComponentEvent = Struct.new(:component)

  class ComponentAddedEvent < ComponentEvent; end
  class ComponentDeletedEvent < ComponentEvent; end
end
