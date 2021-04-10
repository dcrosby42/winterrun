require "spec_helper"

describe "Cedar::Resources::ResourceLoader" do
  let(:res_dir) { "spec/cedar/resources/testfiles" }

  let :resource_loader do
    Cedar::Resources::ResourceLoader.new(dir: res_dir)
  end

  describe "#load_image" do
    it "returns the indicated image" do
      img = resource_loader.load_image "girl_sprite_sheet.png"
      expect(img).not_to be_nil
      expect(img).to be_a Gosu::Image
      expect(img.width).to eq 252
    end

    it "throws for missing image" do
      expect(lambda do resource_loader.load_image "zoinks" end).to raise_error(/Resource file.*zoinks/)
    end
  end

  describe "#load_file" do
    it "returns the content of the named file" do
      text = resource_loader.load_file "any_file.txt"
      expect(text).to eq "When Chuck Norris does division, there are no remainders."
    end

    it "throws for missing file" do
      expect(lambda do resource_loader.load_file "zoinks" end).to raise_error(/Resource file.*zoinks/)
    end
  end

  describe "#load_data" do
    it "returns parsed JSON" do
      data = resource_loader.load_data "a_json_file.json"
      expect(data).to eq({ "answer": 42 })
    end

    it "returns parsed YAML" do
      data = resource_loader.load_data "a_yaml_file.yaml"
      expect(data).to eq({ "crouching" => "tiger" })

      data = resource_loader.load_data "another_yaml_file.yml"
      expect(data).to eq({ "hidden" => "Chuck" })
    end

    it "throws for missing file" do
      expect(lambda do resource_loader.load_data "zoinks" end).to raise_error(/Resource file.*zoinks/)
    end
  end
end
