class TimerSystem
  attr_accessor :res

  def update(timer, input)
    if timer.alarm
      if timer.loop
        timer.t = 0
        timer.alarm = false
      end
    else
      timer.t += input.time.dt
      if timer.t > timer.limit
        timer.t = timer.limit
        timer.alarm = true
      end
    end
  end
end
