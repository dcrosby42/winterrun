require "cedar/ecs/component"

module Cedar
  Pos = Component.new(:pos, { x: 0, y: 0 })
  Vel = Component.new(:vel, { dx: 0, dy: 0 })
  Flip = Component.new(:flip, { x: false, y: false })
  Timer = Component.new(:timer, { t: 0, limit: 1, alarm: false, loop: false })
  Sprite = Component.new(:sprite, { id: nil, frame: 0, scale: 1 })
end