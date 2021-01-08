# Extend Cedar::Helpers with ECS conveniences
module Cedar
  def self.define_system(*types, &update)
    search = CompSearch.new(types.flatten)
    BasicSystem.new(search, update)
  end

  module Helpers
    include Cedar

    def define_system(*types, &update)
      Cedar.define_system(*types, &update)
    end
  end
end
