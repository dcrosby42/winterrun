module Cedar

  # Advances time on Anim components,
  # recomputes Sprite id/frame based on assocatied anim func.
  SpriteAnimSystem = self.define_system(Anim, Sprite) do |e, input, res|
    e.anim.t += (input.time.dt * e.anim.factor)
    anim = res.get_animation(e.anim.id)
    sprite_id, frame_id = anim.call(e.anim.t)
    e.sprite.id = sprite_id
    e.sprite.frame = frame_id
  end
end
