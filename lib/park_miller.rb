# Park-Miller RNG
class ParkMiller
  A = 48271
  B = 0x7FFFFFFF  # == (2**31) - 1

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

    # Return a randomly selected item from an array
    def choose(s, arr)
      i, s = self.int(s, 0, arr.length - 1)
      [arr[i], s]
    end

    # Return a randomly-ordered copy of the given array
    def shuffle(s, arr)
      arr = arr.clone
      res = []
      n = arr.count
      n.times do
        i, s = int(s, 0, arr.count - 1)
        res << arr.delete_at(i)
      end
      [res, s]
    end

    # Uses Ruby's builtin random (non deterministicly) to return a generator state
    def rand_state
      (Kernel.rand * B).to_i
    end

    def gen_seed(s)
      s = call(s)
      seed = s
      seed += 1111
      seed *= 2222
      seed -= 3333
      seed %= B
      [seed, s]
    end

    # def gen_seeds(state, count = 1)
    #   s = state
    #   seeds = []
    #   count.times do
    #     s = call(s)
    #     seeds << s.hash % B
    #   end
    #   [seeds, s]
    # end
  end

  attr_accessor :state

  def initialize(state = nil)
    @state = state || self.class.rand_state
  end

  def next(churn = 1)
    churn.times do
      @state = self.class.call(@state)
    end
    @state
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

  def choose(arr)
    x, @state = self.class.choose(@state, arr)
    x
  end

  def shuffle(arr)
    res, @state = self.class.shuffle(@state, arr)
    res
  end

  def gen_seed
    seed, @state = self.class.gen_seed(@state)
    seed
  end

  def gen_rng
    self.class.new(gen_seed)
  end
end
