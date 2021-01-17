# Extend Cedar::Helpers with ECS conveniences
module Cedar
  module Helpers
    include Cedar

    # Convenience for defining a basic Component-type-matching, iterating system
    def define_system(*types, &update)
      Cedar.define_system(*types, &update)
    end

    # Combine 1 or more systems into a single (lambda) system that simply executes each system in sequence
    def chain_systems(*systems)
      lambda do |estore, input, res|
        systems.flatten.each do |s|
          s.call estore, input, res
        end
      end
    end
  end
end
