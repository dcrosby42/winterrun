class Cedar::Resources::ImageSprite < Cedar::Resources::BaseSprite
  def initialize(name:, images:, scale_x: nil, scale_y: nil, center_x: nil, center_y: nil)
    super name: name, scale_x: scale_x, scale_y: scale_y, center_x: center_x, center_y: center_y
    @images = images
  end

  def frame_count
    @images.length
  end

  def image_for_frame(i)
    @images[i % frame_count]
  end

  def self.category
    :sprite
  end

  def self.construct(config:, resources:)
    images = config[:image] || config[:images] || raise("ImageSprite requires :image or :images")
    images = case images
      when Array
        images
      when String
        [images]
      else
        raise("Cannot use #{images} for :images in ImageSprite config")
      end
    images = images.map do |name|
      resources.get_image(name)
    end
    new(name: config[:name], images: images)
  end
end
