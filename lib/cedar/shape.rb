module Cedar
  module Shape
    module RectOps
      def left; x; end
      def right; x + w; end
      def top; y; end
      def bottom; y + h; end
      def half_h; h / 2; end
      def half_w; w / 2; end
      def center_x; x + half_w; end
      def center_y; y + half_h; end
      def center; [center_x, center_y]; end

      def mul(mx, my)
        r = clone
        r.x = x * mx
        r.w = w * mx
        r.y = y * my
        r.h = h * my
        r
      end
    end

    Rect = Struct.new(:x, :y, :w, :h, keyword_init: true) do
      include RectOps
    end
    Vec2 = Struct.new(:x, :y)
    Point = Vec2
  end
end
