require "modules/bg_tester"
require "modules/spritesheet_tester"

module Switcher
  extend self

  def new_state
    open_struct({
      modules: [
        new_module_handle(BgTester),
        new_module_handle(SpritesheetTester),
      ],
      selected_index: 0,
    })
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
    mod = current(state)
    mod.klass.update(mod.state, input, res)
    state
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
