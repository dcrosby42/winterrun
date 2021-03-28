require "spec_helper"

describe Cedar::CachingEntityStore do
  module TestComps
    extend Cedar::ComponentFactory
  end

  Pos = TestComps.new(:pos, { x: 0, y: 0 })
  Grape = TestComps.new(:grape, { size: 0, color: :green })

  class TestFilter < Cedar::EntityFilter
    def call_count
      @call_count || 0
    end

    def call(e)
      @call_count ||= 0
      @call_count += 1
      super
    end
  end

  let :estore do Cedar::CachingEntityStore.new end

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

    describe "when block is passed, and components are added " do
      it "properly attaches listener such that ComponentAddedEvents are properly emitted during adds in the block" do
        filter = Cedar::EntityFilter.new(Pos)
        hits = estore.search(filter) # causes the filter to be registered
        expect(hits).to be_empty
        e1 = estore.new_entity do |e|
          e.add(Grape.new(size: 4, color: :red))
          e.add(Pos.new(x: 10, y: 100))
        end
        hits = estore.search(filter) # causes the filter to be registered
        expect(hits).to match_array([e1])
      end
    end
  end

  describe "#entities" do
    before do
      ents # realize
    end
    it "returns an Enumerator of all the Entity objects" do
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
      it "returns a simple enumerable" do
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

    describe "when given an EntityFilter" do
      let :filter1 do TestFilter.new(:pos) end
      let :filter2 do TestFilter.new(:grape) end

      before do
        e0, e1, e2 = ents
        e0.add(Pos.new(x: 10, y: 100))
        e0.add(Grape.new(size: 4, color: :red))
        e1.add(Pos.new(x: 123, y: 456))
        e2.add(Grape.new(size: 1))
      end

      it "returns the entities matched by the filter" do
        res = estore.search(filter1)
        expect(res).to match_array([ents[0], ents[1]])

        res = estore.search(filter2)
        expect(res).to match_array([ents[0], ents[2]])
      end

      it "caches the results based on teh filter" do
        estore.search(filter1)
        expect(filter1.call_count).to eq ents.count

        # call again
        res = estore.search(filter1)
        expect(res).to match_array([ents[0], ents[1]])
        # (once more)
        res = estore.search(filter1)
        expect(res).to match_array([ents[0], ents[1]])
        # see filter was not further invoked:
        expect(filter1.call_count).to eq ents.count
      end

      it "evicts cached data for filters affected by component events" do
        # prime cache
        res = estore.search(filter1)
        expect(res).to match_array([ents[0], ents[1]])
        estore.search(filter1)
        estore.search(filter1)
        expect(filter1.call_count).to eq ents.count

        # add Pos to the 3rd entity, which should impact filter1
        ents[2].add(Pos.new)
        # re-search:
        res = estore.search(filter1)
        # see the third component in the results
        expect(res).to match_array([ents[0], ents[1], ents[2]])
        # see the filters were reinvoked:
        expect(filter1.call_count).to eq(2 * ents.count)

        # see cache remains
        estore.search(filter1)
        estore.search(filter1)
        expect(filter1.call_count).to eq(2 * ents.count)

        # remove a comp
        ents[1].remove(:pos)

        # see the results updated
        res = estore.search(filter1)
        expect(res).to match_array([ents[0], ents[2]])
        expect(filter1.call_count).to eq(3 * ents.count)
      end
    end
  end

  describe Cedar::CachingEntityStore::Cache do
    let :cache do Cedar::CachingEntityStore::Cache.new end

    let :e1 do
      e = Cedar::Entity.new(1)
      e.add(Pos.new(x: 10, y: 100))
      e.add(Grape.new(size: 4, color: :red))
      e
    end

    let :e2 do
      e = Cedar::Entity.new(2)
      e.add(Pos.new(x: 123, y: 456))
      e
    end

    let :e3 do
      e = Cedar::Entity.new(3)
      e.add(Grape.new(size: 1))
      e
    end

    let :entities do [e1, e2, e3] end

    let :filter1 do TestFilter.new(:pos) end
    let :filter2 do TestFilter.new(:grape) end

    describe "#get" do
      it "returns two entities that have Pos" do
        res = cache.get(entities, filter1)
        expect(res).to match_array([e1, e2])
      end

      it "returns two entities that have Grape" do
        res = cache.get(entities, filter2)
        expect(res).to match_array([e1, e3])
      end

      it "caches results per filter" do
        # Run filter 1
        res1 = cache.get(entities, filter1)
        expect(res1).to match_array([e1, e2])
        expect(filter1.call_count).to eq(entities.length)

        # Re-run filter 1, see same results but no more filter calls
        res2 = cache.get("bogus", filter1)
        expect(res2).to match_array(res1)
        expect(filter1.call_count).to eq(entities.length)

        # Run filter 2
        res3 = cache.get(entities, filter2)
        expect(res3).to match_array([e1, e3])
        expect(filter2.call_count).to eq(entities.length)

        # Re-run filter 2, see same results but no more filter calls
        res4 = cache.get("bogus", filter2)
        expect(res4).to match_array(res3)
        expect(filter2.call_count).to eq(entities.length)

        # Re-run filter 1 again, see results but no more filter calls
        res2 = cache.get("bogus", filter1)
        expect(res2).to match_array(res1)
        expect(filter1.call_count).to eq(entities.length)
      end
    end

    describe "#handle_event" do
      it "does nothing when no filters have run" do
        cache.handle_event(Cedar::ComponentAddedEvent.new("meh"))
      end

      it "clears cache for a filter if the filter is affected_by_event?" do
        # prime the cache:
        cache.get(entities, filter1)
        cache.get(entities, filter2)

        # Disrupt any filters using Pos-type comps
        evt1 = Cedar::ComponentAddedEvent.new(Pos.new)
        cache.handle_event(evt1)

        # Run filter 1 again,
        res = cache.get(entities, filter1)
        expect(res).to match_array([e1, e2])
        # see the filters all ran again:
        expect(filter1.call_count).to eq(2 * entities.length)

        # Run filter 2, see cache still intact:
        res = cache.get("nerp", filter2)
        expect(res).to match_array([e1, e3])
        expect(filter2.call_count).to eq(entities.length)

        # Disrupt any filters using Grape-type comps
        evt2 = Cedar::ComponentDeletedEvent.new(Grape.new)
        cache.handle_event(evt2)

        # Run filter 2 again,
        res = cache.get(entities, filter2)
        expect(res).to match_array([e1, e3])
        # see the filters all ran again:
        expect(filter2.call_count).to eq(2 * entities.length)
      end

      it "does nothing for uninteresting events" do
        cache.get(entities, filter1)
        cache.get(entities, filter2)

        cache.handle_event("buwuhh?")

        # Re-run filter 1, see same results but no more filter calls
        res = cache.get("bogus", filter1)
        expect(res).to match_array([e1, e2])
        expect(filter1.call_count).to eq(entities.length)

        # Re-run filter 2, see same results but no more filter calls
        res = cache.get("bogus", filter2)
        expect(res).to match_array([e1, e3])
        expect(filter2.call_count).to eq(entities.length)
        expect(filter1.call_count).to eq(entities.length)
      end
    end
  end
end
