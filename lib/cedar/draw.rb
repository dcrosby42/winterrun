module Cedar
  module Draw
    Rect = Struct.new(:x, :y, :z, :w, :h, :color, :mode, keyword_init: true) do
      def draw(res)
        Gosu.draw_rect(x, y, w, h, color || Gosu::Color::WHITE, z || 100, mode || :default)
      end
    end

    Line = Struct.new(:x1, :y1, :x2, :y2, :z, :color, :color2, :mode, keyword_init: true) do
      def draw(res)
        c1 = color || Gosu::Color::WHITE
        c2 = color2 || c1
        Gosu.draw_line(x1, y1, c1, x2, y2, c2, z || 100, mode || :default)
      end
    end

    Image = Struct.new(:image, :path, :x, :y, :z, :scale_x, :scale_y, :subimage, keyword_init: true) do
      def draw(res)
        img = image || res.images(path || raise("Image needs :image or :path"))
        if subimage
          img = img.subimage(*subimage)
        end
        img.draw(x, y, z || 0, scale_x || 1, scale_y || 1)
      end
    end

    Label = Struct.new(:text, :font, :x, :y, :z, :scale_x, :scale_y, :color, keyword_init: true) do
      def draw(res)
        res.fonts(font || :default).draw_text(text, x || 0, y || 0, z || 0, scale_x || 1, scale_y || 1, color || Gosu::Color::WHITE)
      end
    end

    class Sequence
      def initialize
        @drawables = []
      end

      def clear
        @drawables.clear
      end

      def <<(dr)
        case dr
        when Array
          @drawables.concat(dr)
        else
          @drawables << dr
        end
      end

      def draw(res)
        @drawables.each do |d| d.draw(res) end
      end
    end

    class ScaleTransform < Sequence
      def initialize(scale_x, scale_y = nil)
        super()
        @scale_x = scale_x
        @scale_y ||= @scale_x
      end

      def draw(res)
        Gosu.scale(@scale_x, @scale_y) do
          super
        end
      end
    end
  end
end
