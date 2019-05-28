require 'spec_helper'

describe Billimatic::Resources::Subscription do
  let(:entity_klass) { Billimatic::Entities::Subscription }
  let(:http) { Billimatic::Http.new('4d34754cd68bbe74d725f6c8c9f6b48f') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#show :token' do
    it 'returns the subscription that has the token attached' do
      VCR.use_cassette('subscriptions/show_by_token/success') do
        subscription = subject.show(token: '330b961a1969e7ac435c811594c46e8e')

        expect(subscription).to be_a entity_klass
        expect(subscription.token).to eql '330b961a1969e7ac435c811594c46e8e'
        expect(subscription.state).to eql('active')
        expect(subscription.status).to eql('established')
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
        plan_id: 1,
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
            state: "SP"
          }
        }
      }
    end

    it 'returns the newly created subscription' do
      VCR.use_cassette('subscriptions/create/success') do
        subscription = subject.create(subscription_params)

        expect(subscription).to be_a entity_klass
        expect(subscription.name).to eql 'Assinatura Empresa de Teste - TESTE BILLIMATIC Myfinance Bronze'
        expect(subscription.status).to eql 'trial'
        expect(subscription.state).to eql 'active'
        expect(subscription.plan.id).to eql subscription_params.fetch(:plan_id)
      end
    end

    it 'returns an error if plan is not found' do
      VCR.use_cassette('subscriptions/create/plan_not_found') do
        subscription_params[:plan_id] = 80000

        expect {
          subject.create(subscription_params)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end

  describe '#change_plan' do
    it 'returns not found if subscription token is wrong' do
      VCR.use_cassette('/subscriptions/change_plan/failure/wrong_token') do
        expect {
          subject.change_plan(token: "FOO", new_plan_id: 2)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'returns not found when plan is not found' do
      VCR.use_cassette('/subscriptions/change_plan/failure/plan_not_found') do
        expect {
          subject.change_plan(token: "ec0aebe3ed4bd79fd4c238c0b6470c4a", new_plan_id: 800000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'successfully processes plan change on subscription' do
      VCR.use_cassette('/subscriptions/change_plan/success') do
        subscription = subject.change_plan(
          token: "ec0aebe3ed4bd79fd4c238c0b6470c4a", new_plan_id: 2
        )

        expect(subscription).to be_a entity_klass
        expect(subscription.plan.id).to eql 2
      end
    end
  end

  describe '#cancel' do
    it "successfully sets a subscription to 'cancelled' and cancel_date as today" do
      VCR.use_cassette('subscriptions/cancel/success/without_params') do
        subscription = subject.cancel(token: 'dad1b1d450e528c6436ed153d7ab7c42')

        expect(subscription.status).to eql 'cancelled'
        expect(subscription.state).to eql 'inactive'
        expect(subscription.cancel_date).to eql Date.parse('2017-04-10')
        expect(subscription.cancel_reason).to be_nil
      end
    end

    it 'successfully cancels subscription and sets cancel_date' do
      VCR.use_cassette('subscriptions/cancel/success/with_cancel_date') do
        subscription = subject.cancel(
          token: '1870c414e05ac8a6dfb3c529b0a790f6',
          cancel_date: Date.parse("04-09-2017")
        )

        expect(subscription.status).to eql 'cancelled'
        expect(subscription.state).to eql 'inactive'
        expect(subscription.cancel_date).to eql Date.parse('2017-09-04')
        expect(subscription.cancel_reason).to be_nil
      end
    end

    it 'successfully cancels subscription and sets cancel_reason' do
      VCR.use_cassette('subscriptions/cancel/success/with_cancel_reason') do
        subscription = subject.cancel(
          token: '330b961a1969e7ac435c811594c46e8e',
          cancel_reason: "Cancelamento via API de e-commerce"
        )

        expect(subscription.status).to eql 'cancelled'
        expect(subscription.state).to eql 'inactive'
        expect(subscription.cancel_date).to eql Date.parse('2017-04-10')
        expect(subscription.cancel_reason).to eql "Cancelamento via API de e-commerce"
      end
    end

    it 'successfully cancels subscription and sets both cancellation params' do
      VCR.use_cassette('subscriptions/cancel/success/with_cancellation_params') do
        subscription = subject.cancel(
          token: '0a06eeefb50a512dc1403225e26496f8',
          cancel_date: Date.parse("08/04/2017"),
          cancel_reason: "Cancelamento via API de e-commerce"
        )

        expect(subscription.status).to eql 'cancelled'
        expect(subscription.cancel_date).to eql Date.parse('2017-04-08')
        expect(subscription.cancel_reason).to eql "Cancelamento via API de e-commerce"
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
      expect(url).to eq("https://test.host/subscriptions/checkout/foobar")
    end
  end
end
