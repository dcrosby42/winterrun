require "spec_helper"

describe "Cedar::Resources.files" do
  let(:res) { Cedar::Resources.new(dir: "spec/cedar/testfiles/res1") }
  it "can load and parse json files" do
    data = res.files["girl_run.spritesheet.json"]
    expect(data).not_to be_nil
    # spot check:
    expect(data[:type]).to eq "grid_sprite_sheet"
    expect(data[:tile_grid][:y]).to eq 36
  end
end

describe "Cedar::Resources.sprites" do
  let(:res) { Cedar::Resources.new(dir: "spec/cedar/testfiles/res1") }

  it "can load a single image sprite config" do
    list = res.sprites.load({ type: :image_sprite, name: "mysprite", paths: ["gilius.png"] })
    s = list.first
    expect(s).to be
    expect(s.name).to eq("mysprite")
    expect(s).to be_instance_of(Cedar::Resources::ImageSprite)
    expect(s.frame_count).to eq 1
    img = s.image_for_frame(0)
    expect(img).not_to be_nil
    # (quick check the modulo)
    expect(s.image_for_frame(1)).to equal img
    expect(s.image_for_frame(100)).to equal img
    # see the sprite can be accessed by name
    expect(res.sprites["mysprite"]).to equal s
  end

  it "can load a multi-image sprite config" do
    list = res.sprites.load({ type: :image_sprite, name: "dwarves", paths: ["gilius.png", "gilius_cg.png"] })
    s = list.first
    expect(s).to be
    expect(s.name).to eq("dwarves")
    expect(s).to be_instance_of(Cedar::Resources::ImageSprite)
    expect(s.frame_count).to eq 2
    expect(s.image_for_frame(0)).not_to be_nil
    expect(s.image_for_frame(1)).not_to be_nil
    # (quick check the modulo)
    expect(s.image_for_frame(2)).to equal(s.image_for_frame(0))
    expect(s.image_for_frame(3)).to equal(s.image_for_frame(1))
    # see the sprite can be accessed by name
    expect(res.sprites["dwarves"]).to equal s
  end

  it "can load a sprite sheet" do
    list = res.sprites.load({
      "type": "grid_sprite_sheet",
      "name": "girl_run",
      "path": "girl_sprite_sheet.png",
      "tile_grid": {
        "x": 0,
        "y": 36,
        "w": 36,
        "h": 36,
        "count": 8,
        "stride": 3,
      },
    })
    s = list.first
    expect(s).not_to be_nil
    expect(res.sprites["girl_run"]).to equal s
    expect(s.frame_count).to eq 8
    expect(s.image_for_frame(0)).not_to be_nil
    expect(s.image_for_frame(7)).not_to be_nil
    # see the imgs are actually different
    expect(s.image_for_frame(7)).not_to equal(s.image_for_frame(0))
    # check modulo / wrap-around
    expect(s.image_for_frame(8)).to equal(s.image_for_frame(0))
  end

  it "can load a sprite sheet from file" do
    list = res.sprites.load("girl_run.spritesheet.json")
    s = list.first
    # (same as prior spec from here down:)
    expect(s).not_to be_nil
    expect(res.sprites["girl_run"]).to equal s
    expect(s.frame_count).to eq 8
    expect(s.image_for_frame(0)).not_to be_nil
    expect(s.image_for_frame(7)).not_to be_nil
    # see the imgs are actually different
    expect(s.image_for_frame(7)).not_to equal(s.image_for_frame(0))
    # check modulo / wrap-around
    expect(s.image_for_frame(8)).to equal(s.image_for_frame(0))
  end

  it "can load several sprite sheets from file" do
    all = res.sprites.load("girl_anims.spritesheet.json")
    expect(all).not_to be_nil
    expect(all.length).to eq 4
    expect(all.map(&:name)).to contain_exactly("girl_run", "girl_stand", "girl_jump", "girl_biff")
    stand = res.sprites["girl_stand"]
    expect(stand).not_to be_nil
    expect(stand.frame_count).to eq 1
    run = res.sprites["girl_run"]
    expect(run).not_to be_nil
    expect(run.frame_count).to eq 8
  end
end
