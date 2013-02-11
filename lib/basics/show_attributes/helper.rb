module ShowAttributes
  module Helper
    def boolean_tag(value, nil_as_false = false)
      content_tag :i, nil, :class => boolean_icon(value, nil_as_false)
    end

    def boolean_icon(value, nil_as_false)
      if value
        'icon-ok'
      elsif nil_as_false or value == false
        'icon-remove'
      end
    end

    def label_methods
      [:to_label, :name, :title, :email, :created_at, :to_s]
    end

    def association_name(object, association)
      method = label_method(object.send(association))
      object.send(association).send(method) if method
    end

    def label_method(object)
      label_methods.detect { |x| object.respond_to?(x) }
    end

    def label_name(object)
      method = label_method(object)
      # TODO: datetime check?
      if method.in?(:created_at, :updated_at)
        l object.send(method)
      else
        object.send(method)
      end
    end

    def reflection_for(attribute)
      resource_class.reflect_on_association(attribute)
    end
  end
end