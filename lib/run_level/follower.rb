module RunLevel
  FollowTarget = Component.new(:follow_target, { name: nil })
  Follower = Component.new(:follower, { target_name: nil, off_x: 0, off_y: 0 })

  Follower_filter = EntityFilter.new(Follower, Pos)
  FollowTarget_filter = EntityFilter.new(FollowTarget, Pos)

  FollowerSystem = lambda do |estore, input, res|
    estore.search(Follower_filter).each do |ef|
      want = ef.follower.target_name
      et = estore.search(FollowTarget_filter).find do |et| want == et.follow_target.name end
      ef.pos.x = et.pos.x - ef.follower.off_x
      ef.pos.y = et.pos.y - ef.follower.off_y
    end
  end
end
