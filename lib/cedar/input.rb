Cedar::Input = Struct.new(
  :time,       # Cedar::GameTime
  :keyboard,   # Cedar::Keyboard
  :mouse,      # Cedar::Mouse
  :window,     # Gosu::Window
  :did_reload, # bool
  :did_reset # bool
)
