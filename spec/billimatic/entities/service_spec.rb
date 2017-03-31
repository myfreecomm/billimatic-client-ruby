require 'spec_helper'

describe Billimatic::Entities::Service do
  let(:attributes) do
    {
      id: 1,
      name: 'Serviço',
      description: 'Descrição do serviço',
      unit_value: 150.0,
      units: 2.0,
      value: 300.0
    }
  end

  subject { described_class.new(attributes) }

  it { is_expected.to be_a Billimatic::Entities::EntityServiceItem }

  context 'as a subclass of EntityServiceItem' do
    it_behaves_like 'entity_attributes', [:id, :name, :description, :unit_value, :units, :value, :_destroy]
  end
end
