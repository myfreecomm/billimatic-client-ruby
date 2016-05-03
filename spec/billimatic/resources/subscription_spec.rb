require 'spec_helper'

describe Billimatic::Resources::Subscription do
  let(:entity_klass) { Billimatic::Entities::Subscription }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
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
        contract = subject.create(subscription_params)

        expect(contract).to be_a entity_klass
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
end
