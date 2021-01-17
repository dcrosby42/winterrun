require "cedar/ecs"

class PlayerCharacter
  def initialize
    @x = 10
    @y = 100
    @dir = :right
    @sprite_id = "girl_stand"
    @dx = 0
    @anim_t = 0
    @fps = 24
    @run_speed = 100
  end

  def update(input, res)
    if input.keyboard.down?(Gosu::KB_LEFT)
      @dir = :left
      @dx = -@run_speed
    elsif input.keyboard.down?(Gosu::KB_RIGHT)
      @dir = :right
      @dx = @run_speed
    else
      @dx = 0
    end

    @x = @x + (@dx * input.time.dt)

    prev_sprite_id = @sprite_id
    @sprite_id = @dx == 0 ? "girl_stand" : "girl_run"
    if prev_sprite_id != @sprite_id
      @anim_t = 0
    else
      @anim_t += input.time.dt
    end

    sprite = res.sprites[@sprite_id]
    @frame = (@anim_t / (1.0 / @fps)).floor % sprite.frame_count
  end

  def render(res)
    Cedar::Draw::SheetSprite.new(
      sprite_id: @sprite_id,
      sprite_frame: @frame,
      x: @x,
      y: @y,
      scale_x: @dir == :left ? -1 : 1,
      z: 100,
    )
  end
end

module PlayTester
  extend self

  def new_state
    open_struct({
      p1: PlayerCharacter.new(),
    })
  end

  def load_resources(state, res)
    puts "PlayTester.load_resources"
    res.sprites.load("girl_sprite.json")
  end

  def update(state, input, res)
    state.p1.update(input, res)

    state
  end

  ZOrder = open_struct(
    MAIN: 10,
  )

  def draw(state, output, res)
    output.graphics << Cedar::Draw::Scale.new(2) do |t|
      t << state.p1.render(res)
    end
  end
end
