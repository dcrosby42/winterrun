require "spec_helper"

describe "Cedar::Resources" do
  let(:res_dir) { "spec/cedar/resources/testfiles" }

  let :resource_loader do
    Cedar::Resources::ResourceLoader.new(dir: res_dir)
  end

  let :resources do
    Cedar::Resources.new(resource_loader: resource_loader)
  end

  describe "#get_image" do
    it "works" do
      img = resources.get_image "girl_sprite_sheet.png"
      expect(img).not_to be_nil
      expect(img).to be_a Gosu::Image
      expect(img.width).to eq 252
    end
  end

  describe "#get_file" do
    it "works" do
      text = resources.get_file "any_file.txt"
      expect(text).to eq "When Chuck Norris does division, there are no remainders."
    end
  end

  describe "#get_data" do
    it "works" do
      data = resource_loader.load_data "a_json_file.json"
      expect(data).to eq({ "answer": 42 })
    end
  end

  describe "(with some registered fake-ish resource types)" do
    before do
      resources.register_object_type(FakeSprite)
      resources.register_object_type(FakeSprite2)
      resources.register_object_type(FakeAnim)

      resources.configure([{
        "type" => "fake_sprite",
        name: "roundhouse", # test with_indifferent_access
        "spin" => 180,
      }, {
        type: "fake_sprite2",
        name: "double_roundhouse",
        spin: 360,
      }])
      resources.configure({
        "type" => "FakeAnim",
        "name" => "roundhouse",
        "framerate" => 10000,
      })
    end

    describe "#get_sprite" do
      it "works" do
        sprite = resources.get_sprite("roundhouse")
        expect(sprite[:fake_sprite]).to be true
        expect(sprite[:config][:spin]).to eq 180
        expect(sprite[:resources]).to be resources

        sprite = resources.get_sprite("double_roundhouse")
        expect(sprite[:fake_sprite2]).to be true
        expect(sprite[:config][:spin]).to eq 360
        expect(sprite[:resources]).to be resources
      end
    end

    describe "#get_animation" do
      it "works" do
        anim = resources.get_animation("roundhouse")
        expect(anim[:fake_anim]).to be true
        expect(anim[:config][:framerate]).to eq 10000
        expect(anim[:resources]).to be resources
      end
    end

    it "can load complicated files" do
      resources.configure("fake_sprites.json")

      expect(resources.get_sprite("fromfile1")).not_to be_nil
      expect(resources.get_sprite("fromfile2")).not_to be_nil
      expect(resources.get_sprite("fromfile3")).not_to be_nil
      expect(resources.get_animation("animfromfile1")).not_to be_nil
      expect(resources.get_animation("animfromfile2")).not_to be_nil
    end

    it "raises when asking for unconfigured resources" do
      expect(lambda do resources.get_animation("animfromfile3") end).to raise_error(/Can't find animation constructor.*animfromfile3/)
      expect(lambda do resources.get_sprite("bork") end).to raise_error(/Can't find sprite constructor.*bork/)
    end
  end

  class FakeSprite
    def self.category; :sprite; end
    def self.construct(config:, resources:)
      open_struct(fake_sprite: true, config: config, resources: resources)
    end
  end

  class FakeSprite2
    def self.category; :sprite; end
    def self.construct(config:, resources:)
      open_struct(fake_sprite2: true, config: config, resources: resources)
    end
  end

  class FakeAnim
    def self.category; :animation; end
    def self.construct(config:, resources:)
      open_struct(fake_anim: true, config: config, resources: resources)
    end
  end

  describe "(with some genuine registered resource types)" do
    before do
      resources.register_object_type(Cedar::Resources::ImageSprite)
      resources.register_object_type(Cedar::Resources::GridSheetSprite)
      resources.register_object_type(Cedar::Resources::CyclicSpriteAnimation)

      resources.configure([
        "test_girl_sprite.json",
        "test_snowy_background.json",
        {
          type: "cyclic_sprite_animation",
          name: "girl_run",
          sprite: "girl_run",
          fps: 24,
        },
        {
          type: :image_sprite,
          name: "dwarves",
          images: ["gilius.png", "gilius_cg.png"],
        },
      ])
    end

    it "can load ImageSprite objects" do
      %w|bg_l0 bg_l1|.each do |name|
        spr = resources.get_sprite(name)
        expect(spr).not_to be_nil
        expect(spr).to be_instance_of(Cedar::Resources::ImageSprite)
      end
    end

    it "can load a multi-image ImageSprite" do
      gilius = resources.get_sprite("dwarves")
      expect(gilius).not_to be_nil
      i1 = gilius.image_for_frame(0)
      i2 = gilius.image_for_frame(1)
      expect(i1.width).not_to eq i2.width
    end

    it "can load GridSheetSprite objects" do
      %w|girl_run girl_stand girl_jump girl_biff|.each do |name|
        spr = resources.get_sprite(name)
        expect(spr).not_to be_nil
        expect(spr).to be_instance_of(Cedar::Resources::GridSheetSprite)
      end
    end

    it "can load CyclicAnimation objects" do
      anim = resources.get_animation("girl_run")
      expect(anim).not_to be_nil
      expect(anim).to be_instance_of(Cedar::Resources::CyclicSpriteAnimation)
    end
  end
end
