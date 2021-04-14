class Cedar::Resources::BaseSprite
  attr_reader :name, :scale_x, :scale_y, :center_x, :center_y

  def initialize(name:, scale_x: nil, scale_y: nil, center_x: nil, center_y: nil)
    @name = name
    @scale_x = scale_x || 1.0
    @scale_y = scale_y || 1.0
    @center_x = center_x || 0.0
    @center_y = center_y || 0.0
  end

  def frame_count
    1
  end

  def image_for_frame(i)
    raise("BaseSprite#image_for_frame not implemented")
  end
end
