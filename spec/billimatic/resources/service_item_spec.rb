require 'spec_helper'

describe Billimatic::Resources::ServiceItem do
  let(:entity_klass) { Billimatic::Entities::ServiceItem }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#list' do
    it 'returns all service_items for an account' do
      VCR.use_cassette('/service_items/list/success/all_service_items') do
        result = subject.list

        expect(result).not_to be_empty
        expect(result.count).to eql 2

        service_item = result.first
        expect(service_item).to be_a(entity_klass)
      end
    end
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

  describe '#create' do
    it 'successfully creates a new service item' do
      VCR.use_cassette('/service_items/create/success') do
        service_item = subject.create(
          name: 'New Service Item', value: 200.0, description: 'Description'
        )

        expect(service_item).to be_a entity_klass
        expect(service_item.name).to eql 'New Service Item'
      end
    end

    it 'raises Billimatic::RequestError if request is invalid' do
      VCR.use_cassette('/service_items/create/failure/invalid_parameters') do
        expect {
          subject.create(value: 100.0)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError on an attempt to create a duplicated service_item' do
      VCR.use_cassette('/service_items/create/failure/duplicate_service_item') do
        expect {
          subject.create(name: 'Serviço Online 1', value: 200.0)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end
  end

  describe '#update' do
    it 'successfully updates a service item' do
      VCR.use_cassette('/service_items/update/success') do
        service_item = subject.update(
          57, name: 'Service Item Updated', value: 450.0
        )

        expect(service_item).to be_a entity_klass
        expect(service_item.name).to eql 'Service Item Updated'
        expect(service_item.value).to eql 450.0
      end
    end

    it 'raises Billimatic::RequestError when service item is not found' do
      VCR.use_cassette('/service_items/update/failure/service_item_not_found') do
        expect {
          subject.update(2000, name: 'Service Item Updated')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError when service item is invalid' do
      VCR.use_cassette('/service_items/update/failure/invalid_service_item_parameters') do
        expect {
          subject.update(57, name: '')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end
  end

  describe '#destroy' do
    it 'successfully deletes a service item' do
      VCR.use_cassette('/service_items/destroy/success') do
        expect(subject.destroy(58)).to be true
      end
    end

    it 'raises Billimatic::RequestError if service item is not found' do
      VCR.use_cassette('/service_items/destroy/failure/service_item_not_found') do
        expect {
          subject.destroy(20000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if service item is attached to a serviceable resource' do
      VCR.use_cassette('/service_items/destroy/failure/attached_to_a_serviceable') do
        expect {
          subject.destroy(57)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end
  end
end
