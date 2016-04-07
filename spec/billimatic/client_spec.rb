require "spec_helper"

describe Billimatic::Client do
  let(:token) { "45d4e96c707f2a45f73ac9848ff8eeab" } #user login my_favorite_billimatic_user@mailinator.com, passw: 123123
  subject { described_class.new(token) }

  describe "#authenticated?" do
    context "with a valid token" do
      it "returns true" do
        VCR.use_cassette("client/authenticated/true") do
          expect(subject.authenticated?).to be_truthy
        end
      end
    end

    context "with an invalid token" do
      subject { described_class.new("FAKE-TOKEN") }

      it "returns false" do
        VCR.use_cassette("client/authenticated/false") do
          expect(subject.authenticated?).to be_falsey
        end
      end
    end
  end

  describe "#plans" do
    it "returns an instance of Billimatic::Resources::Plan" do
      expect(subject.plans).to be_a(Billimatic::Resources::Plan)
    end
  end

  describe "#subscriptions" do
    it "returns an instance of Billimatic::Resources::Subscription" do
      expect(subject.subscriptions).to be_a(Billimatic::Resources::Subscription)
    end
  end

  describe "#contracts" do
    it "returns an instance of Billimatic::Resources::Contract" do
      expect(subject.contracts).to be_a(Billimatic::Resources::Contract)
    end
  end

  describe "#invoices" do
    it "returns an instance of Billimatic::Resources::Invoice" do
      expect(subject.invoices).to be_a(Billimatic::Resources::Invoice)
    end
  end

  describe "#invoice_rules" do
    it "returns an instance of Billimatic::Resources::InvoiceRule" do
      expect(subject.invoice_rules).to be_a(Billimatic::Resources::InvoiceRule)
    end
  end

  describe "#companies" do
    it "returns an instance of Billimatic::Resources::Company" do
      expect(subject.companies).to be_a(Billimatic::Resources::Company)
    end
  end

  describe "#webhooks" do
    it "returns an instance of Billimatic::Resources::Webhook" do
      expect(subject.webhooks).to be_a(Billimatic::Resources::Webhook)
    end
  end

end
