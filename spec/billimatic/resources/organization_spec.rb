require 'spec_helper'

describe Billimatic::Resources::Organization do
  let(:entity_klass) { Billimatic::Entities::Organization }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end
end
