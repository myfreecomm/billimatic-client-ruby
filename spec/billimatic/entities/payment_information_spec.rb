require 'spec_helper'

describe Billimatic::Entities::PaymentInformation do
  let(:attributes) do
    {
      id: 1,
      payment_method: 'payment_gateway',
      cobrato_card_id: 100,
      card_expiration_month: 12,
      card_expiration_year: 2020
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :payment_method, :cobrato_card_id,
                    :card_expiration_month, :card_expiration_year, :created_at
                  ]
end
