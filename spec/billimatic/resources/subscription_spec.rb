require 'spec_helper'

describe Billimatic::Resources::Subscription do
  let(:entity_klass) { Billimatic::Entities::Subscription }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#show :token' do
    it 'returns the subscription that has the token attached' do
      VCR.use_cassette('subscriptions/show_by_token/success') do
        subscription = subject.show(token: 'f7e385a902a9f626addacdcccc90f10e')

        expect(subscription).to be_a entity_klass
        expect(subscription.token).to eql 'f7e385a902a9f626addacdcccc90f10e'
        expect(subscription.name).not_to be_nil
      end
    end

    it 'returns an error if subscription is not found with the given token' do
      VCR.use_cassette('subscriptions/show_by_token/failure') do
        expect {
          subject.show(token: 'foo123')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end

  describe '#create' do
    let(:subscription_params) do
      {
        plan_id: 4,
        customer: {
          name: "Empresa de Teste",
          email: "teste@companhia.com",
          document: "35.511.438/0001-19",
          type: "Company",
          address_information: {
            address: "Praça da Sé",
            number: "12",
            district: "Sé",
            zipcode: "01001000",
            city: "São Paulo",
            state: "SP",
            ibge_code: "3550308"
          }
        }
      }
    end

    it 'returns the newly created subscription' do
      VCR.use_cassette('subscriptions/create/success') do
        subscription = subject.create(subscription_params)

        expect(subscription).to be_a entity_klass
        expect(subscription.name).to eql 'Assinatura Empresa de Teste - Plano 1'
        expect(subscription.status).to eql 'trial'
        expect(subscription.plan.id).to eql subscription_params.fetch(:plan_id)
      end
    end

    it 'returns an error if a subscription already belongs to the same customer' do
      VCR.use_cassette('subscriptions/create/failure') do
        expect {
          subject.create(subscription_params)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'returns an error if plan is not found' do
      VCR.use_cassette('subscriptions/create/plan_not_found') do
        subscription_params.delete(:plan_id)
        subscription_params[:customer][:name] = 'Empresa Teste'
        subscription_params[:customer][:document] = '45.287.485/0001-84'

        expect {
          subject.create(subscription_params)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end

  describe '#cancel' do
    it "successfully sets a subscription to 'cancelled'" do
      VCR.use_cassette('subscriptions/cancel/success') do
        subscription = subject.cancel(token: 'f7e385a902a9f626addacdcccc90f10e')

        expect(subscription.status).to eql 'cancelled'
      end
    end

    it 'returns an error if subscription is not found' do
      VCR.use_cassette('subscriptions/cancel/not_found') do
        expect {
          subject.cancel(token: 'foo123')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end
  describe "#checkout_url" do
    before do
      Billimatic.configuration.host = "https://test.host"
    end

    it "returns url to checkout on Billimatic app" do
      url = subject.checkout_url(token: "foobar")
      expect(url).to eq("https://test.host/api/v1/subscriptions/checkout/foobar")
    end
  end
end
