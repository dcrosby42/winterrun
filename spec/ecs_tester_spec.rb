require "spec_helper"
require "modules/ecs_tester"

describe "stuff in the ecs_tester module" do
  let (:state) { EcsTester.new_state }
  let (:res) { Cedar::Resources.new }
  let (:estore) { state.estore }
  let (:input) { Cedar::Input.new }

  before do
    EcsTester.load_resources(state, res)
  end

  describe "'girl_run' anim" do
    it "properly selects sprite frames based on time" do
      girl_run = res.anims["girl_run"]
      tick = 1.0 / EcsTester::GirlFps
      expect(girl_run[0]).to eq(["girl_run", 0])
      expect(girl_run[0.03]).to eq(["girl_run", 0])
      expect(girl_run[tick]).to eq(["girl_run", 1])
      expect(girl_run[tick * 4]).to eq(["girl_run", 4])
      expect(girl_run[tick * 7.01]).to eq(["girl_run", 7])
      expect(girl_run[tick * 8]).to eq(["girl_run", 0])
      expect(girl_run[tick * 9]).to eq(["girl_run", 1])
    end
  end

  describe "'girl_stand' anim" do
    it "properly selects sprite frames based on time" do
      girl_stand = res.anims["girl_stand"]
      tick = 1.0 / EcsTester::GirlFps
      expect(girl_stand[0]).to eq(["girl_stand", 0])
      expect(girl_stand[0.03]).to eq(["girl_stand", 0])
      expect(girl_stand[tick]).to eq(["girl_stand", 0])
      expect(girl_stand[100]).to eq(["girl_stand", 0])
    end
  end

  describe "AnimSystem" do
    let(:input) {
      Cedar::Input.new.tap do |input|
        input.time = open_struct(dt: 0, millis: 0, dt_millis: 0)
      end
    }
    let(:res) { Cedar::Resources.new }
    let(:system) { EcsTester::AnimSystem }

    it "works" do
      a1_called_with = nil
      res.anims["a1"] = lambda do |t| a1_called_with = t; ["s1", 42] end
      e1 = estore.new_entity do |e|
        e.add Cedar::Sprite.new
        e.add Cedar::Anim.new
      end

      input.time.dt = 0.1

      system.call(estore, input, res)

      expect(e1.anim.t).to eq(0.1)
      expect(e1.sprite.id).to eq("s1")
      expect(e1.sprite.frame).to eq(42)
    end
  end
end