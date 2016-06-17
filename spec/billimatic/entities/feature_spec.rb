require 'spec_helper'

describe Billimatic::Entities::Feature do
  let(:attributes) do
    {
      id: 1,
      description: 'Até 5 usuários',
      value: 'Foo',
      tag: 'tag'
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like 'entity_attributes', [:id, :description, :value, :tag]
end
