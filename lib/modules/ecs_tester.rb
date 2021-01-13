require "cedar/ecs"

module EcsTester
  extend self
  include Cedar
  extend Cedar::Helpers

  MySystem = define_system(Pos) do |e, input, res|
    e.pos.x += e.vel.dx * input.time.dt
    if e.pos.x > 700
      e.vel.dx = -(e.vel.dx.abs)
    elsif e.pos.x < 100
      e.vel.dx = e.vel.dx.abs
    end
  end

  def new_state
    state = open_struct({
      estore: EntityStore.new,
      system: MySystem,
    })
    state.estore.new_entity do |e|
      e.add Sprite.new(id: "girl_stand", scale: 2)
      e.add Pos.new(x: 100, y: 100)
      e.add Vel.new(dx: 200)
    end
    state
  end

  def load_resources(state, res)
    res.sprites.load("files/girl_sprite.json")
  end

  def update(state, input, res)
    state.system.call(state.estore, input, res)
    state
  end

  PosSpriteSearch = CompSearch.new([Pos, Sprite])
  PosSearch = CompSearch.new([Pos])
  DrawSystem = lambda do |estore, output, res|
    estore.search(PosSearch).each do |e|
      if e.sprite
        output.graphics << Draw::SheetSprite.new(
          sprite_id: e.sprite.id,
          x: e.pos.x,
          y: e.pos.y,
          scale_x: e.sprite.scale,
          scale_y: e.sprite.scale,
        )
      end
    end
  end

  def draw(state, output, res)
    DrawSystem.call(state.estore, output, res)
    # state.estore.each_entity do |e|
    #   if e.pos and e.sprite
    #     output.graphics << Draw::SheetSprite.new(
    #       sprite_id: e.sprite.id,
    #       x: e.pos.x,
    #       y: e.pos.y,
    #       scale_x: e.sprite.scale,
    #       scale_y: e.sprite.scale,

    #     )
    #   end
    # end
  end
end
