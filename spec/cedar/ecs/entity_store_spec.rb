require "spec_helper"

describe Cedar::EntityStore do
  module Comps
    extend Cedar::ComponentFactory
  end

  let :estore do Cedar::EntityStore.new end

  let :ents do
    [estore.new_entity, estore.new_entity, estore.new_entity]
  end

  describe "#new_entity" do
    it "creates new Entity instances with unique entity ids" do
      e1 = estore.new_entity
      expect(e1).not_to be_nil
      expect(e1.eid).to eq 1
      e2 = estore.new_entity
      expect(e2).not_to be_nil
      expect(e2.eid).to eq 2
    end

    it "yields the new entity to an optional block" do
      yielded = nil
      returned = estore.new_entity do |e| yielded = e end
      expect(returned).to equal(yielded)
    end
  end

  describe "#entities" do
    before do
      ents # realize
    end
    it "returns an Enumerator, when no block is given" do
      enum = estore.entities
      arr = enum.map do |e| e end
      expect(arr).to match_array(ents)
    end
  end

  describe "#destroy_entities" do
    before do
      ents # realize
    end

    it "removes the entity from the store" do
      expect(estore.entities.count).to eq 3

      e = estore.entities.to_a[1]
      expect(e).to receive(:clear)

      estore.destroy_entity(e)

      expect(estore.entities.count).to eq 2
    end

    it "can operate on an entity id" do
      expect(estore.entities.count).to eq 3

      e = estore.entities.to_a[1]
      expect(e).to receive(:clear)

      estore.destroy_entity(e.eid)

      expect(estore.entities.count).to eq 2
    end

    it "ignores bad entity ids" do
      estore.destroy_entity(55)
      estore.destroy_entity(nil)
      estore.destroy_entity("oops")
    end

    it "ignores entities that aren't currently in the store" do
      e = estore.entities.to_a[1]
      estore.destroy_entity(e)

      expect(e).not_to receive(:clear)
      estore.destroy_entity(e)
    end
  end

  describe "#search" do
    before do
      ents # realize
    end

    describe "when given neither search obj nor block" do
      it "returns a simple Enumerable" do
        enum = estore.search
        arr = enum.map do |e| e end
        expect(arr).to match_array(ents)
      end
    end

    describe "when given a block" do
      it "filters the entity set using the block as a simple predicate" do
        got = estore.search do |e|
          e.eid.even?
        end
        expect(got).to match_array([ents[1]])
      end
    end

    describe "when given a callable filter" do
      it "returns a list of filtered entities" do
        f = ->(e) { e.eid.even? }
        got = estore.search(f)
        expect(got).to match_array([ents[1]])
      end

      it "returns a list of filtered entities (again)" do
        f = ->(e) { e.eid.odd? }
        got = estore.search(f)
        expect(got).to match_array([ents[0], ents[2]])
      end
    end
  end
end
