require 'spec_helper'

describe Billimatic::Resources::Person do
  let(:entity_klass) { Billimatic::Entities::Person }

  before do
    Billimatic.configuration.host = "http://localhost:3000"
    @http = Billimatic::Http.new('d0cb3c0eae88857de3266c7b6dd7298d')
  end

  subject { described_class.new(@http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(@http)
  end

  describe '#search' do
    it 'returns a list of people with matching unformatted document' do
      VCR.use_cassette('/people/search/success/unformatted_document') do
        result = subject.search(cpf: "04814515790")

        expect(result).not_to be_empty
        result.each do |person|
          expect(person).to be_a entity_klass
          expect(person.cpf).to eql "04814515790"
        end
      end
    end

    it 'returns a list of people with matching formatted document' do
      VCR.use_cassette('/people/search/success/formatted_document') do
        result = subject.search(cpf: "048.145.157-90")

        expect(result).not_to be_empty
        result.each do |person|
          expect(person).to be_a entity_klass
          expect(person.cpf).to eql "04814515790"
        end
      end
    end

    it 'returns an empty array if no person matches criteria' do
      VCR.use_cassette('/people/search/success/no_matches') do
        expect(
          subject.search(cpf: "553.973.204-98")
        ).to be_empty
      end
    end
  end
end
