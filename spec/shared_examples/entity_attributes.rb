shared_examples "entity_attributes" do |attrs|
  attrs.each do |attr|
    it { is_expected.to have_attr_accessor(attr) }
  end

  it "expect to cover all attributes" do
    expect(subject.attributes.keys).to match_array(attrs)
  end
end
