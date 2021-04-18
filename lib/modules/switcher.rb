require "modules/play_tester"
require "run_level"
# require "modules/bg_tester"
require "modules/spritesheet_tester"

module Switcher
  extend self

  def new_state
    open_struct({
      modules: [
        new_module_handle(RunLevel),
        new_module_handle(PlayTester),
        # new_module_handle(BgTester),
        new_module_handle(SpritesheetTester),
      ],
      selected_index: 0,
      watch_for_reload: false,
      reload_timer: Cedar::Timer.new({ limit: 1.5, loop: true }),
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
    fx = []

    case
    when input.keyboard.pressed?(Gosu::KB_F1)
      switch_to_module(state, 0)
      reset_module_state(state) if input.keyboard.shift?
    when input.keyboard.pressed?(Gosu::KB_F2)
      switch_to_module(state, 1)
      reset_module_state(state) if input.keyboard.shift?
    when input.keyboard.pressed?(Gosu::KB_F3)
      switch_to_module(state, 2)
      reset_module_state(state) if input.keyboard.shift?
    when input.keyboard.pressed?(Gosu::KB_R) && input.keyboard.alt? && input.keyboard.control?
      state.watch_for_reload = !state.watch_for_reload
      puts "Switcher auto-reload: #{state.watch_for_reload}"
    when input.keyboard.pressed?(Gosu::KB_R) && input.keyboard.shift?
      # Re-initialize the state of the currently running module (without reloading code)
      reset_module_state(state)
    when input.keyboard.pressed?(Gosu::KB_R) && input.keyboard.alt?
      # Check for code reload
      fx << Cedar::Sidefx::Reload.new
    end

    # fullscreen toggle?
    fx << Cedar::Sidefx::ToggleFullscreen.new if input.keyboard.pressed?(Gosu::KB_F11)

    if state.watch_for_reload
      # reload timer
      Cedar.update_timer state.reload_timer, input.time.dt
      fx << Cedar::Sidefx::Reload.new if state.reload_timer.alarm
    end

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
    puts "Reset module state"
  end
end
