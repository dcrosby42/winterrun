# Extend Cedar::Helpers with ECS conveniences
module Cedar
  module Helpers
    include Cedar

    def define_system(*types, &update)
      Cedar.define_system(*types, &update)
    end
  end
end
