require 'spec_helper'

describe Billimatic::Resources::InvoiceTemplate do
  let(:entity_klass) { Billimatic::Entities::InvoiceTemplate }
  let(:http) { Billimatic::Http.new('4d34754cd68bbe74d725f6c8c9f6b48f') }

  subject { described_class.new(http) }

  describe '#list' do
    it 'raises Billimatic::RequestError when organization is not found' do
      VCR.use_cassette('invoice_templates/list/failure/organization_not_found') do
        expect {
          subject.list(organization_id: 1_000_000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'returns a collection with all invoice_templates from organization' do
      VCR.use_cassette('invoice_templates/list/success/full_collection') do
        result = subject.list(organization_id: 486)

        expect(result.count).to eql 3

        result.each do |template|
          expect(template).to be_a entity_klass
        end
      end
    end
  end

  describe '#show' do
    it 'raises Billimatic::RequestError when organization is not found' do
      VCR.use_cassette('invoice_templates/show/failure/organization_not_found') do
        expect {
          subject.show(16, organization_id: 1_000_000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError when template is not found' do
      VCR.use_cassette('invoice_templates/show/failure/template_not_found') do
        expect {
          subject.show(1_000_000, organization_id: 1)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'returns invoice_template entity found by id on organization' do
      VCR.use_cassette('invoice_templates/show/success/found_by_id') do
        result = subject.show(6, organization_id: 486)

        expect(result).to be_a entity_klass
        expect(result.id).to eql 6
        expect(result.name).to eql 'Template com serviços'

        expect(result.services.count).to eql 3
        result.services.each do |service|
          expect(service).to be_a Billimatic::Entities::Service
        end

        expect(result.gross_value).to eql 189.9

        expect(
          result.receivables_additional_information
        ).to include('charge_type' => 'last_day_of_month', 'parcel_number' => 2)
      end
    end
  end
end
