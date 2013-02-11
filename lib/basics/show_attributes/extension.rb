module ShowAttributes
  module Extension
    def show_attributes(object, type = :dl, options = { }, &block)
      css_class = options.delete(:class)
      css_class ||= 'dl-horizontal'
      content   = capture(ShowAttributes::Base.new(object, type), &block)
      case type
      when :dl
        content_tag(:dl, content, :class => css_class)
      else
        content
      end
    end

  end
end

ActionView::Base.send :include, ShowAttributes::Extension