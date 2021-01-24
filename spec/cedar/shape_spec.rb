require "spec_helper"
describe Cedar::Shape::Rect do
  describe "simple rect" do
    let(:rect) { Cedar::Shape::Rect.new(x: 100, y: 200, w: 50, h: 30) }
    it "has all the expected dimensions" do
      expect(rect.x).to eq 100
      expect(rect.y).to eq 200
      expect(rect.w).to eq 50
      expect(rect.h).to eq 30

      expect(rect.left).to eq 100
      expect(rect.right).to eq 150
      expect(rect.top).to eq 200
      expect(rect.bottom).to eq 230
      expect(rect.half_w).to eq 25
      expect(rect.half_h).to eq 15
      expect(rect.center_x).to eq 125
      expect(rect.center_y).to eq 215
      expect(rect.center_y).to eq 215
    end
  end
  describe "empty rect" do
    let(:rect) { Cedar::Shape::Rect.new }
    it "has 0 for all vals" do
      expect(rect.left).to eq 0
      expect(rect.right).to eq 0
      expect(rect.top).to eq 0
      expect(rect.bottom).to eq 0
      expect(rect.half_w).to eq 0
      expect(rect.half_h).to eq 0
      expect(rect.center_x).to eq 0
      expect(rect.center_y).to eq 0
      expect(rect.center_y).to eq 0
    end
  end

  describe "rect with non-even dimensions" do
    let(:rect) { Cedar::Shape::Rect.new(x: 10, y: 10, w: 11, h: 9) }
    it "uses floating point devision to find the half measures" do
      expect(rect.x).to eq 10
      expect(rect.y).to eq 10
      expect(rect.w).to eq 11
      expect(rect.h).to eq 9
      expect(rect.half_w).to be_within(0.0001).of(5.5)
      expect(rect.half_h).to be_within(0.0001).of(4.5)
      expect(rect.center_x).to be_within(0.0001).of(15.5)
      expect(rect.center_y).to be_within(0.0001).of(14.5)
    end
  end
end
