class Cedar::Resources::CyclicSpriteAnimation
  def self.category
    :animation
  end

  def self.construct(config:, resources:)
    new(
      name: config[:name],
      sprite_name: config[:sprite],
      fps: config[:fps],
      frame_count: resources.get_sprite(config[:sprite]).frame_count,
    )
  end

  def initialize(name:, sprite_name:, fps:, frame_count:)
    @name = name
    @sprite_name = sprite_name
    @fps = fps
    @frame_count = frame_count
  end

  def call(t)
    frame = (t * @fps).to_i % @frame_count
    [@sprite_name, frame]
  end
end
