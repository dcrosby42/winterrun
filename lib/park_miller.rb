# Park-Miller RNG
class ParkMiller
  A = 48271
  B = 2147483647

  class << self
    # next generator state
    def call(s)
      (s * A) % B
    end

    alias_method :[], :call

    # new random float [lo,hi), defaults to [0,1)
    def float(s, lo = 0.0, hi = 1.0)
      s = call(s)
      [(s.to_f / B) * (hi - lo) + lo, s]
    end

    alias_method :rand, :float

    # new random int [lo,hi]
    def int(s, lo, hi)
      f, s = float(s)
      i = (f * (hi - lo + 1)).to_i + lo
      [i, s]
    end

    # returns true if next rand [0,1.0) <= prob.
    # Default behavior is pron=0.5, ie, a coin toss.
    def chance(s, prob = 0.5)
      f, s = float(s)
      [f <= prob, s]
    end
  end

  attr_accessor :state

  def initialize(state = nil)
    @state = state || (rand * 100000).to_i + 10000
  end

  def next
    @state = self.class.call(@state)
  end

  def float(lo = 0.0, hi = 1.0)
    f, @state = self.class.float(@state, lo, hi)
    f
  end

  alias_method :rand, :float

  def int(lo, hi)
    i, @state = self.class.int(@state, lo, hi)
    i
  end

  def chance(prob = 0.5)
    b, @state = self.class.chance(@state, prob)
    b
  end
end
