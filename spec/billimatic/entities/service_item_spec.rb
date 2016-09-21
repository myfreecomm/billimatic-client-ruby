require 'spec_helper'

describe Billimatic::Entities::ServiceItem do
  let(:attributes) do
    {
      id: 1,
      account_id: 2,
      name: 'Serviço',
      description: 'Descrição do serviço',
      value: 200.99,
      unit: 'item'
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [
                    :id, :account_id, :name,
                    :description, :value, :unit
                  ]
end
