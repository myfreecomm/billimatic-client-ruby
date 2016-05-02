require 'spec_helper'

describe Billimatic::Resources::Plan do
  let(:entity_klass) { Billimatic::Entities::Plan }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#list' do
    it 'returns a collection of plans for an organization' do
      VCR.use_cassette('plans/list/success') do
        plans = subject.list(564)
        entity_service_items = plans.each.map(&:products).flatten

        expect(plans).to be_a Array
        plans.each do |plan|
          expect(plan).to be_a entity_klass
        end

        entity_service_items.each do |entity_service_item|
          expect(entity_service_item).
            to be_a Billimatic::Entities::EntityServiceItem
        end
      end
    end

    it 'returns not found it the organization is not found' do
      VCR.use_cassette('plans/list/organization_not_found') do
        expect { subject.list(51) }.to raise_error(
                                         Billimatic::RequestError
                                       ) { |error| expect(error.code).to eql(404) }
      end
    end
  end
end
