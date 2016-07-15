require "spec_helper"

describe Billimatic::UrlHelpers do
  subject { described_class.instance }

  describe "#checkout_url" do
    it "returns the checkout url" do
      expect(subject.checkout_url(token: "some-subscription-token")).to eql(
        "https://sandbox.billimatic.com.br/subscriptions/checkout/some-subscription-token")
    end
  end

  describe "#subscription_dashboard_url" do
    it "returns the checkout url" do
      expect(subject.subscription_dashboard_url(token: "some-subscription-token")).to eql(
        "https://sandbox.billimatic.com.br/subscriptions/some-subscription-token/dashboard")
    end
  end

  describe "#change_plan_url" do
    it "returns the checkout url" do
      expect(subject.change_plan_url(token: "some-subscription-token", plan_id: 52)).to eql(
        "https://sandbox.billimatic.com.br/subscriptions/some-subscription-token/change_plan/52")
    end
  end
end
