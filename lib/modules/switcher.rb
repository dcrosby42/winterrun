require "systems/timer_system"
require "modules/play_tester"
# require "modules/bg_tester"
# require "modules/spritesheet_tester"

module Switcher
  extend self

  def new_state
    open_struct({
      modules: [
        new_module_handle(PlayTester),
      # new_module_handle(BgTester),
      # new_module_handle(SpritesheetTester),
      ],
      selected_index: 0,
      reload_timer: Timer.new({ limit: 1.5, loop: true }),
    })
  end

  def load_resources(state, res)
    state.modules.each do |mod|
      mod.klass.load_resources(mod.state, res) if mod.klass.respond_to?(:load_resources)
    end
  end

  def new_module_handle(mklass)
    open_struct(klass: mklass, state: mklass.new_state)
  end

  def update(state, input, res)
    case
    when input.keyboard.pressed?(Gosu::KB_F1)
      switch_to_module(state, 0)
      reset_module_state(state) if input.keyboard.shift?
    when input.keyboard.pressed?(Gosu::KB_F2)
      switch_to_module(state, 1)
      reset_module_state(state) if input.keyboard.shift?
    when input.keyboard.pressed?(Gosu::KB_R) && input.keyboard.shift?
      reset_module_state(state)
    end

    fx = []

    # fullscreen toggle?
    fx << Cedar::Sidefx::ToggleFullscreen.new if input.keyboard.pressed?(Gosu::KB_F11)

    # reload timer
    TimerSystem.new.update state.reload_timer, input
    fx << Cedar::Sidefx::Reload.new if state.reload_timer.alarm

    # update module state
    mod = current(state)
    s1, mfx = mod.klass.update(mod.state, input, res)
    mod.state = s1 unless s1.nil?

    fx.concat(mfx) if Array === mfx

    [state, fx]
  end

  def draw(state, output, res)
    mod = current(state)
    mod.klass.draw(mod.state, output, res)
  end

  def current(state)
    state.modules[state.selected_index]
  end

  def switch_to_module(state, i)
    state.selected_index = i
  end

  def reset_module_state(state)
    mod = current(state)
    mod.state = mod.klass.new_state
  end
end
