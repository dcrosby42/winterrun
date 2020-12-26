class Cedar::Output
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
