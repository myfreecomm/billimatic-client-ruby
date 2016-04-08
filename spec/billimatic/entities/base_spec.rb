require 'spec_helper'

describe Billimatic::Entities::Base do

  class DummyEntity < Billimatic::Entities::Base
    attribute :property_1, String
    attribute :property_2, String
  end

  let(:hash) { {property_1: 1, property_2: 2} }
  subject    { DummyEntity.new(hash) }

  it "builds an object from a hash" do
    expect(subject).to respond_to(:property_1)
    expect(subject).to respond_to(:property_2)
    expect(subject.property_1).to eq("1")
    expect(subject.property_2).to eq("2")
  end

  describe "#attributes" do
    it "returns a hash from object attributes" do
      expect(subject.to_hash).to eq({
        property_1: "1",
        property_2: "2"
      })
    end
  end
end
