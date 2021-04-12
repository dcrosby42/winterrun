require "spec_helper"
require "cedar/ecs"

describe Cedar::Component do
  # Cedar::Component is the default ComponentFactory, and thus registers
  # all the default standard comps etc. Rather than mess that around,
  # let's work off an alternate component factory:
  module TestComps
    extend Cedar::ComponentFactory
  end

  Grape2 = TestComps.new(:grape, { size: 0, color: :green })

  describe ".new" do
    it "defines a new type of component" do
      g = Grape2.new(eid: 42, size: 5, color: :red)
      expect(g).not_to be_nil
      expect(g.eid).to equal 42
      expect(g.size).to equal 5
      expect(g.color).to equal :red
    end

    describe "creates a new Component class that" do
      it "has a .type class method" do
        expect(Grape2.type).to equal :grape
      end

      it "has a .props class method that returns the properties and defailts" do
        expect(Grape2.props).to eq({ size: 0, color: :green, eid: nil })
      end

      it "has a #type instance method and .type class method" do
        expect(Grape2.new.type).to equal :grape
      end

      it "has defaults" do
        g = Grape2.new
        expect(g.eid).to be_nil
        expect(g.size).to equal 0
        expect(g.color).to equal :green
      end

      it "partially applies defaults" do
        g = Grape2.new(eid: 12, color: :red)
        expect(g.eid).to equal 12
        expect(g.size).to equal 0
        expect(g.color).to equal :red
      end

      it "provides read/write attrs" do
        g = Grape2.new
        g.eid = 50
        g.size = 100
        g.color = :gold
        expect(g.eid).to equal 50
        expect(g.size).to equal 100
        expect(g.color).to equal :gold
      end

      it "raises on unexpected constructor args" do
        expect { Grape2.new(pits: "pointy") }.to raise_error(/:pits/)
      end

      it "can convert to a Hash" do
        g = Grape2.new(eid: 42, size: 5, color: :red)
        expect(g.to_h).to eq({ type: :grape, eid: 42, size: 5, color: :red })
      end
    end
  end

  describe ".from_h" do
    it "registers a deserializer for the new comp type" do
      comp = TestComps.from_h({ type: :grape, eid: 37, size: 5, color: :purp })
      expect(comp.eid).to equal 37
      expect(comp.size).to equal 5
      expect(comp.color).to equal :purp
    end
  end
end
