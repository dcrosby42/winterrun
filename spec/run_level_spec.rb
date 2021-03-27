require "spec_helper"
require "run_level"

describe "stuff in the RunLevel module" do
  let (:state) { RunLevel.new_state }
  let (:res) { Cedar::Resources.new }
  let (:estore) { state.estore }
  let (:input) { Cedar::Input.new }

  before do
    RunLevel.load_resources(state, res)
  end

  describe "'girl_run' anim" do
    it "properly selects sprite frames based on time" do
      girl_run = res.anims["girl_run"]
      tick = 1.0 / RunLevel::GirlFps
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
      tick = 1.0 / RunLevel::GirlFps
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
    let(:system) { RunLevel::AnimSystem }

    it "increments animation time and updates the sprite" do
      a1_called_with = nil
      res.anims["a1"] = lambda do |t| a1_called_with = t; ["s1", 42] end
      e1 = estore.new_entity do |e|
        e.add Cedar::Sprite.new
        e.add Cedar::Anim.new(id: "a1")
      end

      input.time.dt = 0.1

      system.call(estore, input, res)

      expect(e1.anim.t).to eq(0.1)
      expect(a1_called_with).to eq(e1.anim.t)
      expect(e1.sprite.id).to eq("s1")
      expect(e1.sprite.frame).to eq(42)

      system.call(estore, input, res)
      system.call(estore, input, res)

      expect(e1.anim.t).to be_within(0.0001).of(0.3)
      expect(a1_called_with).to eq(e1.anim.t)
    end
  end

  describe "#paralax_calc" do
    it "works" do
      x = 0
      w = 720
      f = 1
      tw = 1421
      g = lambda do
        RunLevel::paralax_calc(x, w, f, tw)
      end
      fail "FINISH HIM"
    end
  end

  describe "ParalaxSystem" do
    it "works" do
      fail "FIXME"
      # binding.pry
      RunLevel::ParalaxSystem.(estore, input, res)
      # binding.pry
    end
  end
end
