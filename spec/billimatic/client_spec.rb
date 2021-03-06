require "spec_helper"

describe Billimatic::Client do
  let(:token) { "bfe97f701f615edf41587cbd59d6a0e8" } # user login my_favorite_billimatic_user@mailinator.com, passw: 123456
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

  describe "#organizations" do
    it "returns an instance of Billimatic::Resources::Organization" do
      expect(subject.organizations).to be_a(Billimatic::Resources::Organization)
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

  describe "#invoice_templates" do
    it "returns an instance of Billimatic::Resources::InvoiceTemplate" do
      expect(subject.invoice_templates).to be_a(Billimatic::Resources::InvoiceTemplate)
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

  describe "#people" do
    it "returns an instance of Billimatic::Resources::Person" do
      expect(subject.people).to be_a(Billimatic::Resources::Person)
    end
  end

  describe "#service_items" do
    it "returns an instance of Billimatic::Resources::ServiceItem" do
      expect(subject.service_items).to be_a(Billimatic::Resources::ServiceItem)
    end
  end

  describe "#webhooks" do
    it "returns an instance of Billimatic::Resources::Webhook" do
      expect(subject.webhooks).to be_a(Billimatic::Resources::Webhook)
    end
  end

  describe "#email_templates" do
    it "returns an instance of Billimatic::Resources::EmailTemplate" do
      expect(subject.email_templates).to be_a(Billimatic::Resources::EmailTemplate)
    end
  end
end
