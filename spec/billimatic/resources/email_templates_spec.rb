require 'spec_helper'

describe Billimatic::Resources::EmailTemplate do
  let(:entity_klass) { Billimatic::Entities::EmailTemplate }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#list' do
    before do
      Billimatic.configuration.host = "http://localhost:3000"
      Typhoeus::Expectation.clear
      @http = Billimatic::Http.new('0131ed0f662e6fdb3ba8ab9cff35c14a')
    end

    subject { described_class.new(@http) }

    it 'raises Billimatic::RequestError when organization is not found' do
      VCR.use_cassette('/email_templates/list/failure/organization_not_found') do
        expect {
          subject.list(organization_id: 50_000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql(404)
        end
      end
    end

    it 'returns collection of email templates on organization' do
      VCR.use_cassette('/email_templates/list/success/not_empty_collection') do
        result = subject.list(organization_id: 12)

        expect(result).not_to be_empty

        result.each do |email_template|
          expect(email_template).to be_a entity_klass
          expect(email_template.id).to eql 17
        end
      end
    end
  end
end
