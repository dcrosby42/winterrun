module Cedar
  # Set/get Cedar runtime mode.  :dev :prod :test
  # Impacts behavior of auto reload checking, resource name collision checks etc.
  def self.mode(m = nil)
    if !m.nil?
      m = m.to_sym
      raise ("Cedar.mode accepts one of :dec, :test, :prod") unless [:dev, :prod, :test].include?(m)
      @_mode = m
    end
    if @_mode.nil?
      if ENV["CEDAR_MODE"]
        if [:dev, :prod, :test].include?(ENV["CEDAR_MODE"].to_sym)
          @_mode = ENV["CEDAR_MODE"].to_sym
        else
          $stderr.puts "!! CEDAR_MODE must be 'dev' or 'test' or 'prod', not #{ENV["CEDAR_MODE"].inspect}"
        end
      end
      @_mode ||= :dev  # fallback
    end
    @_mode
  end
end

module Cedar::Helpers; end

require "gosu"
require "active_support"
require "active_support/core_ext"
require "cedar/to_recursive_ostruct"
require "cedar/shape"
require "cedar/autoreload"
require "cedar/resources"
require "cedar/input"
require "cedar/game"
require "cedar/keyboard"
require "cedar/mouse"
require "cedar/game_time"
require "cedar/sidefx"
require "cedar/draw"
require "cedar/output"
