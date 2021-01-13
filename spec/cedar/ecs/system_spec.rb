require "spec_helper"
require "cedar/ecs"

describe "Cedar.define_system" do
  let(:calls) do [] end
  let(:system) do
    Cedar.define_system(Cedar::Pos, Cedar::Timer) do |e, input, res|
      calls << [e, input, res]
    end
  end

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
  let(:input) { "fake input" }
  let(:res) { "fake res" }

  before do
    ents # make sure we actually generate the Entities in the estore
  end

  it "works" do
    system.call(estore, input, res)

    # expect(calls.lenjgth).to eq 2
    expect(calls).to contain_exactly(
      [ents[0], input, res],
      [ents[4], input, res]
    )
  end
end
