require "spec_helper"

describe Billimatic::Exception do

  class DummyError < Billimatic::Exception; end

  subject do
    DummyError.new(
      body: "FAKE BODY",
      message: "FAKE MESSAGE",
      code: 42
    )
  end

  it "responds to the correct accessors" do
    expect(subject.body).to eq("FAKE BODY")
    expect(subject.message).to eq("FAKE MESSAGE")
    expect(subject.code).to eq(42)
    expect(subject.to_s).to eq("FAKE MESSAGE")
  end
end
