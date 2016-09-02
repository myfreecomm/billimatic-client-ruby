require 'spec_helper'

describe Billimatic::Entities::PlanFeature do
  let(:attributes) do
    {
      id: 1,
      description: 'Até 5 usuários',
      value: 'Foo',
      tag: 'tag',
      _destroy: false
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [:id, :description, :value, :tag, :_destroy]
end
