module ShowAttributes
  class Base < Struct.new(:object, :type)
    include ::ActionView::Helpers
    include Helper

    def show(column)
      case type
      when :dl
        dl(column)
      end
    end

    def column(name)
      Column.new(object, name)
    end

    def title(name)
      column(name).title
    end

    def value(name)
      column(name).value
    end

    def dl(name)
      c      = column(name)
      output = content_tag(:dt, c.title, title: c.title)
      output << content_tag(:dd, c.value)
      output
    end
  end
end