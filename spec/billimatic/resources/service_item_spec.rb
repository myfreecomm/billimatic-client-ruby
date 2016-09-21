require 'spec_helper'

describe Billimatic::Resources::ServiceItem do
  let(:entity_klass) { Billimatic::Entities::ServiceItem }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#search' do
    it 'retuns successfully the service item with name matching search' do
      VCR.use_cassette('/service_items/search/success') do
        service_item = subject.search(name: 'Serviço Online 1')
        expect(service_item).to be_a entity_klass
        expect(service_item.name).to eql 'Serviço Online 1'
      end
    end

    it 'raises Billimatic::RequestError if name parameter is null' do
      VCR.use_cassette('/service_items/search/failure/null_name_parameter') do
        expect {
          subject.search(name: nil)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'raises Billimatic::RequestError if name parameter is an empty string' do
      VCR.use_cassette('/service_items/search/failure/empty_string_name') do
        expect {
          subject.search(name: '')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'raises Billimatic::RequestError if service item is not found' do
      VCR.use_cassette('/service_items/search/failure/service_item_not_found') do
        expect {
          subject.search(name: 'Foo')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end
end
