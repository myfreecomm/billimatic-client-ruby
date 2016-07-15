require 'spec_helper'

describe Billimatic do

  it 'has a version number' do
    expect(Billimatic::VERSION).not_to be nil
  end

  describe ".configuration" do
    it "is done via block initialization" do
      Billimatic.configure do |c|
        c.host = "http://some/where"
        c.user_agent = "My App v1.0"
      end
      expect(Billimatic.configuration.url).to eq "http://some/where/api/v1"
      expect(Billimatic.configuration.user_agent).to eq "My App v1.0"
    end

    it "uses a singleton object for the configuration values" do
      config1 = Billimatic.configuration
      config2 = Billimatic.configuration
      expect(config1).to eq config2
    end
  end

  describe ".configure" do
    it "returns nil when no block given" do
      expect(Billimatic.configure).to eql(nil)
    end

    it "raise error if no method" do
      expect do
        Billimatic.configure { |c| c.user = "Bart" }
      end.to raise_error(NoMethodError)
    end
  end

  describe ".client" do
    subject { described_class.client("MYTOKEN") }

    it "returns an instance of Billimatic::Client" do
      expect(subject).to be_a(Billimatic::Client)
    end
  end

  describe ".subscribe" do
    class FakePublisher
      include Wisper::Publisher

      def apply
        publish("fake.event")
      end
    end

    it "notifies all listeners about an event occurrence" do
      listener = double("listener")
      expect(listener).to receive(:call).and_return(true)
      described_class.subscribe("fake.event", listener)
      FakePublisher.new.apply
    end
  end

  describe '.signature' do
    subject { described_class.signature("my-secret-key") }

    it "returns an instance of Billimatic::Client" do
      expect(subject).to be_a(Billimatic::Signature)
    end
  end

  describe '.url_helpers' do
    subject { described_class.url_helpers }

    it "returns an instance of Billimatic::UrlHelpers" do
      expect(subject).to be_a(Billimatic::UrlHelpers)
    end
  end
end
