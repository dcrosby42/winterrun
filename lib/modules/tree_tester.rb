# require "cedar/ecs/systems/timer_system"
require "cedar/ecs"

module TreeTester
  extend self

  ZOrder = OpenStruct.new({
    BACKGROUND: 0,
    UNDERGRID: 1,
    SHEET: 5,
    UI: 10,
  })

  def new_state
    return open_struct({})
  end

  def load_resources(state, res)
    puts "load_resources"
    res.configure list_resources
  end

  def list_resources
    [
      "sprites/tree_sprites.json",
    ]
  end

  def update(state, input, res)
  end

  def draw(state, output, res)
    g = output.graphics

    drawimg = lambda do |name, x, y, outline = false|
      g << Cedar::Draw::SheetSprite.new(
        sprite_id: name,
        sprite_frame: 0,
        x: x,
        y: y,
        z: 101,
      )
      if outline
        img = res.get_sprite(name).image_for_frame(0)
        g << Cedar::Draw::RectOutline.new(
          x: x,
          y: y,
          z: 100,
          color: Gosu::Color::BLUE,
          w: img.width,
          h: img.height,
        )
      end
    end

    drawimg["big_tree_01", 30, 0]
    drawimg["big_tree_02", 250, 0]
    drawimg["big_tree_03", 800, 0]
    drawimg["skinny_tree_01", 550, 0]
    drawimg["skinny_tree_02", 660, 0]
    drawimg["skinny_tree_03", 720, 0]

    # g << Cedar::Draw::Label.new(text: "#{tree_sprite.image_for_frame(0).width}")
  end
end
