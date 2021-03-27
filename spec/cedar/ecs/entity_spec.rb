require "spec_helper"
require "cedar/ecs"

describe Cedar::Entity do
  module Comps
    extend Cedar::ComponentFactory
  end

  Loc = Comps.new :loc, x: 0, y: 0
  Sprite = Comps.new :sprite, name: ""

  let :entity do Cedar::Entity.new(42) end

  it "has #eid" do
    expect(entity.eid).to equal 42
  end

  describe "when asked for a component / method it doesn't have" do
    it "raises error" do
      expect { entity.nope }.to raise_error(Cedar::ComponentError, /:nope/)
    end
  end

  describe "#add" do
    it "adds a component to the entity, which becomes available by method" do
      entity.add(Loc.new(x: 10, y: 20))
      expect(entity).to respond_to(:loc)
      expect(entity.loc).not_to be_nil
      expect(entity.loc.eid).to eq entity.eid
      expect(entity.loc.x).to eq 10
      expect(entity.loc.y).to eq 20
    end

    it "raises when a Component of the same type is already present" do
      entity.add(Loc.new)
      expect { entity.add(Loc.new) }.to raise_error(Cedar::ComponentError)
    end

    describe "when _listener is set" do
      it "notifies of :add_comp" do
        events = []
        entity._listener = lambda do |evt|
          events << evt
        end

        c1 = Loc.new
        entity.add(c1)
        expect(events[0]).to be_a Cedar::ComponentAddedEvent
        expect(events[0].component).to eq c1

        c2 = Sprite.new
        entity.add(c2)
        expect(events[1]).to be_a Cedar::ComponentAddedEvent
        expect(events[1].component).to eq c2
      end
    end
  end

  describe "#remove" do
    let :loc do Loc.new(x: 1, y: 2) end

    before do
      entity.add(loc)
    end

    describe "when given a symbol" do
      it "deletes the component of the indicated type" do
        loc = entity.loc

        entity.remove(:loc)
        expect(entity).not_to respond_to(:loc)
        expect { entity.loc }.to raise_error(Cedar::ComponentError)

        # see eid revoked from the component instance:
        expect(loc.eid).to be_nil
      end

      describe "when there's no component of that type" do
        it "raises" do
          entity.remove(:loc)
          expect { entity.remove(:loc) }.to raise_error(Cedar::ComponentError, /:loc/)
        end
      end

      describe "when _listener is set" do
        it "notifies of ComponentDeletedEvent" do
          calls = []
          entity._listener = lambda do |evt|
            calls << evt
          end

          entity.remove(:loc)
          expect(calls[0]).to be_a Cedar::ComponentDeletedEvent
          expect(calls[0].component).to eq loc
        end
      end
    end

    describe "when given a Component" do
      it "deletes the component" do
        loc = entity.loc
        entity.remove(loc)
        expect { entity.loc }.to raise_error(Cedar::ComponentError)
        # see eid revoked from the component instance:
        expect(loc.eid).to be_nil
      end

      describe "when there's no matching component" do
        it "raises" do
          entity.remove(:loc)
          expect { entity.remove(:loc) }.to raise_error(Cedar::ComponentError, /:loc/)
        end
      end

      describe "when _listener is set" do
        it "emits ComponentDeletedEvent" do
          calls = []
          entity._listener = lambda do |evt|
            calls << evt
          end

          entity.remove(:loc)
          expect(calls[0]).to be_a Cedar::ComponentDeletedEvent
          expect(calls[0].component).to eq loc
        end
      end
    end

    describe "when given an oddball object" do
      it "raises" do
        [0, nil, OpenStruct.new].each do |obj|
          expect { entity.remove(obj) }.to raise_error(Cedar::ComponentError)
        end
      end
    end
  end

  describe "#clear" do
    it "removes all components from the entity" do
      entity.add(Loc.new)
      entity.add(Sprite.new)
      expect(entity).to respond_to(:loc)
      expect(entity).to respond_to(:sprite)

      entity.clear

      expect(entity).not_to respond_to(:loc)
      expect(entity).not_to respond_to(:sprite)
    end

    it "notifies as each component is removed" do
      loc = Loc.new
      sprite = Sprite.new
      entity.add(loc)
      entity.add(sprite)

      calls = []
      entity._listener = lambda do |evt|
        calls << evt
      end

      entity.clear

      expect(calls.length).to eq 2
      expect(calls[0]).to be_a Cedar::ComponentDeletedEvent
      expect(calls[0].component).to eq loc
      expect(calls[1]).to be_a Cedar::ComponentDeletedEvent
      expect(calls[1].component).to eq sprite
    end
  end
end
