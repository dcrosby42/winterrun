module Cedar
  # Cedar.update_timer is exposed during development for some consumer code that probably shouldn't be using it.
  def self.update_timer(timer, dt)
    timer = timer
    if timer.alarm
      if timer.loop
        timer.t = 0
        timer.alarm = false
      end
    else
      timer.t += dt
      if timer.t > timer.limit
        timer.t = timer.limit
        timer.alarm = true
      end
    end
  end

  TimerSystem = self.define_system(Timer) do |e|
    update_timer e.timer, input.time.dt
  end
end
