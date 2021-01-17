require "spec_helper"

describe Cedar::Entity do
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

    describe "when given a callable search object" do
      describe "that doesn't support caching" do
        it "passes the entity enum to the search func and returns results" do
          simple_call_count = 0
          simple_search = lambda do |ents|
            simple_call_count += 1
            ["simple results", ents]
          end
          3.times do |i|
            out = estore.search(simple_search)
            expect(out[0]).to eq("simple results")
            expect(out[1]).to match_array(ents)
            expect(simple_call_count).to eq(i + 1)
          end
        end
      end

      describe "that supports caching" do
        class OddCachingSearch
          attr_accessor :call_count, :invalid

          def initialize
            @call_count = 0
            @invalid = false
          end

          def call(entities)
            @call_count += 1
            entities.filter do |e| e.eid.odd? end
          end

          def cache_key; "oddCachingSearch"; end

          def cache_invalid?(events)
            @events = events
            @invalid
          end
        end

        describe "when the entity store hasn't invalidated the cache" do
          it "returns cached results" do
            search = OddCachingSearch.new
            search.invalid = false

            3.times do
              out = estore.search(search)
              expect(out).to match_array([ents[0], ents[2]])
              expect(search.call_count).to eq(1)
            end
          end
        end

        describe "when the EntityStore has invalidated the cache due to our reporting invalid" do
          it "re-runs the search" do
            search = OddCachingSearch.new
            search.invalid = false

            3.times do
              out = estore.search(search)
              expect(out).to match_array([ents[0], ents[2]])
              expect(search.call_count).to eq(1)
            end

            # Now, trigger our search to think it needs to be re-done:
            search.invalid = true # this causes our bogo Search to hint invalidation back to EntityStore
            search.call_count = 0
            estore.update_cache # this is when EntityStore checks cache_invalid?

            # run the search
            out = estore.search(search)
            expect(out).to match_array([ents[0], ents[2]])
            expect(search.call_count).to eq(1)

            # Flip our invalid flag back to normal
            search.invalid = false
            search.call_count = 0
            # Poke the cache again
            estore.update_cache

            # Re-run the search, see we receive cached results
            out = estore.search(search)
            expect(out).to match_array([ents[0], ents[2]])
            expect(search.call_count).to eq(0)
          end
        end
      end

      describe "that has no #cache_key method" do
        class NoCacheKeySearch
          attr_reader :call_count

          def call(entities)
            @call_count ||= 0
            @call_count += 1
            entities.filter do |e| e.eid.even? end
          end

          def cache_invalid?
            false
          end
        end

        it "does not cache results, instread re-running the search func each time" do
          search = NoCacheKeySearch.new
          3.times do |i|
            out = estore.search(search)
            expect(out).to match_array([ents[1]]) # eid=2
            expect(search.call_count).to eq(i + 1)
          end
        end
      end
    end
  end
end
