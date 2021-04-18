module RunLevel
  FollowTarget = Component.new(:follow_target, { name: nil })
  Follower = Component.new(:follower, { target_name: nil, on: true, off_x: 0, off_y: 0, min_x: nil, max_x: nil, min_y: nil, max_y: nil })

  Follower_filter = EntityFilter.new(Follower, Pos)
  FollowTarget_filter = EntityFilter.new(FollowTarget, Pos)

  FollowerSystem = lambda do |estore, input, res|
    estore.search(Follower_filter).each do |ef|
      if ef.follower.on
        # Find the target
        want = ef.follower.target_name
        et = estore.search(FollowTarget_filter).find do |et| want == et.follow_target.name end
        if et
          # Apply pos changes
          ef.pos.x = et.pos.x - ef.follower.off_x
          ef.pos.y = et.pos.y - ef.follower.off_y

          # constrain pos
          if ef.follower.min_y && ef.pos.y < ef.follower.min_y
            ef.pos.y = ef.follower.min_y
          elsif ef.follower.max_y && ef.pos.x > ef.follower.max_y
            ef.pos.y = ef.follower.max_y
          end
        end
      end
    end
  end
end
