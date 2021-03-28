module Cedar
  class EntityFilter
    attr_reader :ident

    def initialize(*types)
      @types = types.flatten.map do |t|
        case
        when t.respond_to?(:type)
          t.type
        else
          t.to_sym
        end
      end
      @ident = @types.sort.map(&:to_s).join(":")
      @hash = @ident.hash
    end

    def call(e)
      @types.all? { |t| e.has?(t) }
    end

    alias_method :[], :call

    def affected_by_event?(evt)
      case evt
      when ComponentAddedEvent, ComponentDeletedEvent
        return @types.include?(evt.component.type)
      end
      false
    end

    def eql?(o)
      o.respond_to?(:ident) && o.ident == self.ident
    end

    def hash
      @hash
    end

    def inspect
      "#<EntityFilter #{@ident}>"
    end

    alias_method :to_s, :inspect
  end
end
