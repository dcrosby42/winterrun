require "cedar/ecs/component"

module Cedar
  Pos = Component.new(:pos, { x: 0, y: 0, z: 0 })
  Vel = Component.new(:vel, { dx: 0, dy: 0 })
  Flip = Component.new(:flip, { x: false, y: false })
  Timer = Component.new(:timer, { t: 0, limit: 1, alarm: false, loop: false })
  Sprite = Component.new(:sprite, { id: nil, frame: 0, scale_x: 1, scale_y: 1, center_x: nil, center_y: nil })
  Anim = Component.new(:anim, { id: nil, t: 0, factor: 1 })
end
