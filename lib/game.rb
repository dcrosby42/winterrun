class Game < Gosu::Window
  Input = Struct.new(:dt, :dt_millis, :millis)

  def initialize(mod)
    w = 1280
    h = 720
    super w, h
    self.caption = "WinterRun"

    @input = Input.new
    @input.millis = 0
    @input.dt_millis = 0
    @input.dt = 0

    @module = mod
    @state = @module.initialState(OpenStruct.new({ w: w, h: h }))
  end

  def update
    last_millis = @input.millis
    @input.millis = Gosu.milliseconds
    @input.dt_millis = @input.millis - last_millis
    @input.dt = @input.dt_millis / 1000.0

    @state = @module.update(@state, @input)
  end

  def draw
    @module.draw(@state)
  end
end
