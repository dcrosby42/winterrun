require "run_level"
require "modules/spritesheet_tester"
require "modules/tree_tester"

module Switcher
  extend self

  Modules = [RunLevel, TreeTester, SpritesheetTester]

  def new_state
    open_struct({
      modules: Modules.map do |m| new_module_handle m end,
      selected_index: 0,
      watch_for_reload: false,
      reload_timer: Cedar::Timer.new({ limit: 1.5, loop: true }),
    })
  end

  def resource_config
    Modules.map(&:resource_config).flatten
  end

  def new_module_handle(mklass)
    open_struct(klass: mklass, state: mklass.new_state)
  end

  def update(state, input, res)
    fx = []

    {
      Gosu::KB_F1 => 0,
      Gosu::KB_F2 => 1,
      Gosu::KB_F3 => 2,
      Gosu::KB_F4 => 3,
      Gosu::KB_F5 => 4,
    }.each do |key, i|
      if input.keyboard.pressed?(key) && i < state.modules.length
        switch_to_module(state, i)
        reset_current_module_state(state, res) if input.keyboard.shift?
      end
    end

    # Manually-invoked code and state reload:
    case
    when input.keyboard.pressed?(Gosu::KB_R)
      if input.keyboard.alt?
        state.watch_for_reload = !state.watch_for_reload
        puts "Code reload timer: #{state.watch_for_reload ? "on" : "off"}"
      else
        if input.keyboard.control?
          puts "Request code-reload check"
          fx << Cedar::Sidefx::ReloadCode.new
        elsif input.keyboard.shift?
          puts "Reset module state"
          reset_current_module_state(state, res)
        end
      end
    end

    # case
    # when input.keyboard.pressed?(Gosu::KB_R) && input.keyboard.alt? && input.keyboard.control?
    #   state.watch_for_reload = !state.watch_for_reload
    #   puts "Switcher auto-reload: #{state.watch_for_reload}"
    # when input.keyboard.pressed?(Gosu::KB_R) && input.keyboard.shift?
    #   # Re-initialize the state of the currently running module (without reloading code)
    #   reset_module_state(state, res)
    # when input.keyboard.pressed?(Gosu::KB_R) && input.keyboard.alt?
    #   # Check for code reload
    #   fx << Cedar::Sidefx::ReloadCode.new
    # end

    # When timer-driven code reload is on:
    if state.watch_for_reload
      # reload timer
      Cedar.update_timer state.reload_timer, input.time.dt
      fx << Cedar::Sidefx::ReloadCode.new if state.reload_timer.alarm
    end

    # fullscreen toggle?
    fx << Cedar::Sidefx::ToggleFullscreen.new if input.keyboard.pressed?(Gosu::KB_F11)

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

  def reset_current_module_state(state, res)
    mod = current(state)
    mod.state = mod.klass.new_state
    res.reset_caches
    mod.klass.load_resources(mod.state, res) if mod.klass.respond_to?(:load_resources)
    puts "Reset module state"
  end
end
