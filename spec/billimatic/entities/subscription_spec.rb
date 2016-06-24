require 'spec_helper'

describe Billimatic::Entities::Subscription do
  let(:attributes) do
    {
      plan_id: 1,
      customer: Billimatic::Entities::Customer.new(
        name: 'Empresa',
        email: 'empresa@teste.com',
        document: '81.700.416/0001-14',
        type: 'Company',
        address_information: Billimatic::Entities::AddressInformation.new(
          address: 'Praça da Sé',
          number: 12,
          district: 'Sé',
          zipcode: '01001000',
          city: 'São Paulo',
          state: 'SP',
          ibge_code: '3550308'
        )
      )
    }
  end

  subject { described_class.new(attributes) }

  it { is_expected.to be_a Billimatic::Entities::Contract }

  context 'as a subclass of Contract' do
    it_behaves_like 'entity_attributes', [
                      :id, :name, :title, :token, :description, :customer_id,
                      :customer_type, :supplier_id, :supplier_type, :state,
                      :init_date, :end_date, :comments, :created_at, :kind,
                      :registration_method, :overdue, :status, :plan
                    ]
  end

  describe '#checkout_url' do
    before do
      Billimatic.configuration.host = "https://test.host"
    end
    it 'returns a full URL to the checkout process for this Subscription' do
      subject.token = 'foo'
      expect(subject.checkout_url).to eq('https://test.host/api/v1/subscriptions/checkout/foo')
    end
  end
end
