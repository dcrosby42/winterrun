module Cedar
  module Shape
    module RectOps
      def left; x; end
      def right; x + w; end
      def top; y; end
      def bottom; y + h; end
      def half_h; h / 2.0; end
      def half_w; w / 2.0; end
      def center_x; x + half_w; end
      def center_y; y + half_h; end

      def mul(mx, my)
        r = clone
        r.x = x * mx
        r.w = w * mx
        r.y = y * my
        r.h = h * my
        r
      end
    end

    class Rect
      include RectOps
      attr_accessor :x, :y, :w, :h

      def initialize(x: 0, y: 0, w: 0, h: 0)
        @x = x
        @y = y
        @w = w
        @h = h
      end
    end

    Vec2 = Struct.new(:x, :y)
    Point = Vec2
  end
end
