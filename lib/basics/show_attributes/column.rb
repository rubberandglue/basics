module ShowAttributes
  class Column < Struct.new(:object, :name)
    include Helper

    NONE = '-'.freeze

    def title
      klass.human_attribute_name(name)
    end

    def value
      if association?
        association_name(object, name).presence || NONE
      elsif boolean?
        boolean_tag(raw_value)
      else
        raw_value.presence || NONE
      end
    end

    def raw_value
      object.send(name)
    end

    private
    def klass
      object.class
    end

    def association?
      klass.reflect_on_association(name)
    end

    def type
      klass.columns_hash[name.to_s].try(:type)
    end

    def boolean?
      type == :boolean
    end
  end
end