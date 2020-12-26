module Cedar
  module Draw
    Image = Struct.new(:path, :x, :y, :z, :scale_x, :scale_y, keyword_init: true) do
      def draw(res)
        res.images[path].draw(x, y, z || 0, scale_x, scale_y)
      end
    end

    Label = Struct.new(:text, :font, :x, :y, :z, :scale_x, :scale_y, keyword_init: true) do
      def draw(res)
        res.fonts[font || :default].draw_text(text, x || 0, y || 0, z || 0, scale_x || 1, scale_y || 1)
      end
    end
  end
end
