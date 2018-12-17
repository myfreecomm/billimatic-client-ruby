require 'spec_helper'

describe Billimatic::Resources::InvoiceTemplate do
  let(:entity_klass) { Billimatic::Entities::InvoiceTemplate }

  before do
    Billimatic.configuration.host = "http://localhost:3000"
    Typhoeus::Expectation.clear
    @http = Billimatic::Http.new('5d09f5c3dc8df35e225ad074b66f47e0')
  end

  subject { described_class.new(@http) }

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
        result = subject.list(organization_id: 1)

        expect(result.count).to eql 11

        result.each do |template|
          expect(template).to be_a entity_klass
        end
      end
    end
  end
end
