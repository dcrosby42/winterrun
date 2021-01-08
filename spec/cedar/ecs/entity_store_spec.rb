require "spec_helper"
require "cedar/ecs"

describe Cedar::Entity do
  module Comps
    extend Cedar::ComponentFactory
  end

  let :estore do Cedar::EntityStore.new end

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

  describe "#each_entity" do
    let :ents do
      [estore.new_entity, estore.new_entity, estore.new_entity]
    end

    it "iterates each existent entity" do
      ents # force creation
      arr = []
      estore.each_entity do |e|
        arr << e
      end
      expect(arr).to match_array(ents)
    end

    it "returns an Enumerator, when no block is given" do
      ents # force creation
      enum = estore.each_entity
      arr = enum.map do |e| e end
      expect(arr).to match_array(ents)
    end
  end
end
