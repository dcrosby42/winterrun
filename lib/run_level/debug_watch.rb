module RunLevel
  DebugWatch = Component.new(:debug_watch, { label: "watch", watches: nil })

  DebugWatch_filter = EntityFilter.new(DebugWatch)
end
