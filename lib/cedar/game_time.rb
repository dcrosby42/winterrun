class Cedar::GameTime
  def initialize
    @millis = nil
    @dt_millis = nil
  end

  def millis
    @millis || 0 # defaults to 0
  end

  def dt_millis
    @dt_millis || 16  # defaults to nominal tick size for first game tick
  end

  def dt
    @dt || (1.0 / 60) # defaults ot nominal frame delta for first game tick
  end

  def t
    @t || 0.0
  end

  def update_to(time_millis)
    if @millis
      @dt_millis = time_millis - @millis
      @dt = @dt_millis / 1000.0
      @t = @millis / 1000.0
    end
    @millis = time_millis
  end
end
