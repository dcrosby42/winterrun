require "spec_helper"
require "cedar/ecs"

describe Cedar::System do
  module Comps
    extend Cedar::ComponentFactory
  end

  Timey = Comps.new :timey, t: 0
  Magnitude = Comps.new :magnitude, value: 0, scalar: 1

  class TimeySystem < Cedar::System
    matches :timey

    def update(e, input, res)
      # puts "update! input.time.dt=#{input.time.dt}"
      e.timey.y += input.time.dt
    end
  end

  class ReverseTimeySystem < Cedar::System
    matches Timey

    def update(e, input, res)
      # puts "update! input.time.dt=#{input.time.dt}"
      e.timey.y -= input.time.dt
    end
  end

  let :estore do Cedar::EntityStore.new end

  let :entities do
    [
      estore.new_entity do |e|
        e.add Timey.new
      end,
      estore.new_entity do |e|
        e.add Magnitude.new
      end,
      estore.new_entity do |e|
        e.add Timey.new
        e.add Magnitude.new
      end,
    ]
  end

  let :e1 do entities[0] end

  let :e2 do entities[1] end

  let :e3 do entities[2] end

  describe "for a System with matched defined by symbol" do
    let :system do TimeySystem.new end

    describe "#match?" do
      it "returns true for entities that match" do
        expect(system).to be_match(e1)
        expect(system).to be_match(e3)
      end

      it "returns false for entities that match" do
        expect(system).not_to be_match(e2)
      end
    end
  end

  describe "for a System with matched defined by component type" do
    let :system do ReverseTimeySystem.new end

    describe "#match?" do
      it "returns true for entities that match" do
        expect(system).to be_match(e1)
        expect(system).to be_match(e3)
      end

      it "returns false for entities that match" do
        expect(system).not_to be_match(e2)
      end
    end
  end

  describe "a System matching multiple component types" do
    class GrowerSystem < Cedar::System
      matches Timey, Magnitude

      def update(e, input, res)
        e.magnitude.value += (e.magnitude.scalar * e.timey.t)
      end
    end

    let :system do GrowerSystem.new end

    describe "#match?" do
      it "returns true for entities that match" do
        expect(system).to be_match(e3)
      end

      it "returns false for entities that match" do
        expect(system).not_to be_match(e2)
        expect(system).not_to be_match(e1)

        e1.add Magnitude.new
        expect(system).to be_match(e1)
      end
    end

    describe "update_all" do
      let :input do open_struct({}) end
      let :res do open_struct({}) end

      it "applies to matching entities" do
        entities
        e3.timey.t = 0.25
        e3.magnitude.scalar = 2

        system.update_all estore, input, res
        expect(e3.magnitude.value).to eq 0.5

        expect(e2.magnitude.value).to eq 0 # e2 has a Magnitude but no Timey

        system.update_all estore, input, res
        expect(e3.magnitude.value).to eq 1
      end
    end
  end

  describe "a CachingSystem" do
    class GrowerSystem2 < Cedar::CachingSystem
      matches Timey, Magnitude

      def update(e, input, res)
        e.magnitude.value += (e.magnitude.scalar * e.timey.t)
      end
    end

    let :system do GrowerSystem2.new end

    describe "update_all" do
      let :input do open_struct({}) end
      let :res do open_struct({}) end

      it "applies to matching entities, but does NOT re-query estore" do
        entities
        e3.timey.t = 0.25
        e3.magnitude.scalar = 2

        expect(estore).to receive(:each_entity).and_call_original
        system.update_all estore, input, res
        expect(e3.magnitude.value).to eq 0.5

        expect(e2.magnitude.value).to eq 0 # e2 has a Magnitude but no Timey

        expect(estore).not_to receive(:each_entity)
        system.update_all estore, input, res
        expect(e3.magnitude.value).to eq 1

        system.update_all estore, input, res
        expect(e3.magnitude.value).to eq 1.5
      end
    end
  end
end
