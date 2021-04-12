require "spec_helper"

describe "Cedar::Resources::GridSheetSprite" do
  let :resources do
    rl = Cedar::Resources::ResourceLoader.new(dir: "spec/cedar/resources/testfiles")
    res = Cedar::Resources.new(resource_loader: rl)
    res.register_object_type(Cedar::Resources::GridSheetSprite)
    res.configure("test_girl_sprite.json")
    res
  end

  it "has .category == :sprite" do
    expect(Cedar::Resources::GridSheetSprite.category).to eq :sprite
  end

  it "can be constructed according to preloaded config" do
    s = resources.get_sprite "girl_run"
    expect(s).not_to be_nil

    expect(s.frame_count).to eq 8

    # make sure we can get images, and we can ask "off the end"
    20.times do |i|
      expect(s.image_for_frame(i)).to be_instance_of(Gosu::Image)
    end
    # make sure the images are different...
    expect(s.image_for_frame(0)).not_to eq(s.image_for_frame(1))
    # ...but repeat:
    expect(s.image_for_frame(0)).to eq(s.image_for_frame(8))
  end
end
