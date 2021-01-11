require "spec_helper"

describe Cedar::CompSearch do
  let(:search) { Cedar::CompSearch.new(Cedar::Pos, Cedar::Timer) }

  let(:estore) { Cedar::EntityStore.new }
  let(:ents) {
    [
      estore.new_entity do |e|
        e.add Cedar::Pos.new(x: 10, y: 10)
        e.add Cedar::Timer.new(limit: 1, loop: true)
      end,
      estore.new_entity do |e|
        e.add Cedar::Pos.new
      end,
      estore.new_entity do |e|
      end,
      estore.new_entity do |e|
        e.add Cedar::Timer.new
      end,
      estore.new_entity do |e|
        e.add Cedar::Timer.new
        e.add Cedar::Pos.new
      end,
    ]
  }

  before do
    ents
    estore.update_cache
  end

  describe "#call" do
    it "returns the entities that match the targeted comp types" do
      out = search.call(ents)
      expect(out).to match_array([ents[0], ents[4]])
    end
  end

  describe "cache_invalid?" do
    let :events do
      {
        add_remove_comp: Hash.new do |h, k| h[k] = [] end,
      }
    end

    describe "when events include an :add_remove_comp event for :pos" do
      it "returns true" do
        events[:add_remove_comp][:pos] << "something"
        expect(search).to be_cache_invalid(events)
      end
    end

    describe "when events include an :add_remove_comp event for :timer" do
      it "returns true" do
        events[:add_remove_comp][:timer] << "something"
        events[:add_remove_comp][:timer] << "something more"
        expect(search).to be_cache_invalid(events)
      end
    end

    describe "when events do not include :add_remove_comp for either target type" do
      it "returns false" do
        events[:add_remove_comp][:other] << "something"
        expect(search).not_to be_cache_invalid(events)
      end
    end
  end

  describe "integrated with actual EntityStore#update_cache usage" do
    it "#call is invoked on first use" do
      expect(search).to receive(:call).and_call_original
      # (ents0 and ents4, at the outset, are the only matching entities)
      expect(estore.search(search)).to match_array([ents[0], ents[4]])
    end

    it "#call is not invoked once cached, and no changes to entities" do
      out = estore.search(search)
      expect(out).to match_array([ents[0], ents[4]])

      expect(search).not_to receive(:call).and_call_original

      3.times do
        estore.update_cache
        expect(estore.search(search)).to match_array([ents[0], ents[4]])
      end
    end

    it "#call remains cached if entity changes are unrelated to the search" do
      out = estore.search(search)
      expect(out).to match_array([ents[0], ents[4]])

      expect(search).not_to receive(:call).and_call_original

      ents[0].add Cedar::Sprite.new # target entity, but comp type not interesting
      estore.update_cache
      expect(estore.search(search)).to match_array([ents[0], ents[4]])

      ents[1].add Cedar::Sprite.new # a different entity
      estore.update_cache
      expect(estore.search(search)).to match_array([ents[0], ents[4]])
    end

    it "cache invalidates if a target entity loses an interesting component" do
      expect(estore.search(search)).to match_array([ents[0], ents[4]])

      ents[0].remove :pos
      estore.update_cache
      # we should see a re-search
      expect(search).to receive(:call).and_call_original
      # ents0 drops out because it no longer has a Pos component
      expect(estore.search(search)).to match_array([ents[4]])
    end

    it "cache invalidates if non-target entities gain interesting components" do
      expect(estore.search(search)).to match_array([ents[0], ents[4]])

      ents[1].add Cedar::Timer.new # ents1 now has both Pos and Timer
      ents[3].add Cedar::Pos.new # ents3 now has both Pos and Timer
      estore.update_cache
      # see a re-search
      expect(search).to receive(:call).and_call_original
      expect(estore.search(search)).to match_array([ents[0], ents[1], ents[3], ents[4]])
    end
  end
end
