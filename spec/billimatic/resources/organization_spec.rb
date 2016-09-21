require 'spec_helper'

describe Billimatic::Resources::Organization do
  let(:entity_klass) { Billimatic::Entities::Organization }
  let(:http) { Billimatic::Http.new('6123247039bf2a14e3f1de59626e7b2d') }

  subject { described_class.new(http) }

  before do
    Billimatic.configuration.host = "http://localhost:3000"
  end

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#search' do
    it 'successfully returns an organization matching formatted cnpj' do
      VCR.use_cassette('/organizations/search/success/formatted_cnpj') do
        organization = subject.search(cnpj: "17.799.377/0001-55")
        expect(organization).to be_a entity_klass
        expect(organization.cnpj).to eql "17.799.377/0001-55"
      end
    end

    it 'successfully returns an organization matching cnpj without any formatting' do
      VCR.use_cassette('/organizations/search/success/unformatted_cnpj') do
        organization = subject.search(cnpj: "17799377000155")
        expect(organization).to be_a entity_klass
        expect(organization.cnpj).to eql "17.799.377/0001-55"
      end
    end

    it 'raises Billimatic::RequestError if cnpj is null' do
      VCR.use_cassette('/organizations/search/failure/null_cnpj') do
        expect {
          subject.search(cnpj: nil)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'raises Billimatic::RequestError if cnpj is an empty string' do
      VCR.use_cassette('/organizations/search/failure/empty_string_cnpj') do
        expect {
          subject.search(cnpj: '')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'raises Billimatic::RequestError if cnpj is not valid' do
      VCR.use_cassette('/organizations/search/failure/invalid_cnpj') do
        expect {
          subject.search(cnpj: 'foo')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if no organizations match the cnpj sent' do
      VCR.use_cassette('/organizations/search/failure/no_organization_matches') do
        expect {
          subject.search(cnpj: '05.784.655/0001-11')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end

  describe '#create' do
    it 'successfully creates an organization with formatted cnpj' do
      VCR.use_cassette('organizations/create/success/formatted_cnpj') do
        organization = subject.create(
          name: "Nova Organização", cnpj: "87.667.729/0001-02"
        )

        expect(organization).to be_a entity_klass
        expect(organization.name).to eql 'Nova Organização'
        expect(organization.cnpj).to eql "87.667.729/0001-02"
      end
    end

    it 'successfully creates an organization with unformatted cnpj' do
      VCR.use_cassette('organizations/create/success/unformatted_cnpj') do
        organization = subject.create(
          name: "Nova Organização com CNPJ sem formato", cnpj: "25029551000109"
        )

        expect(organization).to be_a entity_klass
        expect(organization.name).to eql 'Nova Organização com CNPJ sem formato'
        expect(organization.cnpj).to eql "25.029.551/0001-09"
      end
    end

    it 'raises Billimatic::RequestError if request is invalid' do
      VCR.use_cassette('organizations/create/failure/invalid_parameters') do
        expect {
          subject.create(cnpj: "87.667.729/0001-02")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError when trying to create a duplicate organization' do
      VCR.use_cassette('organizations/create/failure/duplicate_organization') do
        expect {
          subject.create(name: 'Organização', cnpj: "53.724.867/0001-56")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError when cnpj is invalid' do
      VCR.use_cassette('organizations/create/failure/invalid_cnpj') do
        expect {
          subject.create(name: 'Nova Organização', cnpj: "foo")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end
  end
end
