require 'spec_helper'

describe Billimatic::Entities::EntityServiceItem do
  let(:attributes) do
    {
      id: 1,
      name: 'Serviço',
      unit_value: 150.0,
      units: 2.0,
      value: 300.0,
      _destroy: false
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [:id, :name, :unit_value, :units, :value, :_destroy]
end
