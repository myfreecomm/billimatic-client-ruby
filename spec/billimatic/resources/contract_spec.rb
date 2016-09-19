require 'spec_helper'

describe Billimatic::Resources::Contract do
  let(:entity_klass) { Billimatic::Entities::Contract }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#search' do
    context 'sending the full contract name as parameter' do
      it 'returns a collection with contracts matching the name' do
        VCR.use_cassette('/contracts/search/success/full_name_matching') do
          contracts = subject.search('Prestação de Serviço Um')

          expect(contracts).not_to be_empty
          contracts.each do |contract|
            expect(contract).to be_a entity_klass
            expect(contract.name).to eql 'Prestação de Serviço Um'
          end
        end
      end
    end

    context 'sending part of a contract name as parameter' do
      it 'returns a collection with contracts matching the search' do
        VCR.use_cassette('/contracts/search/success/partial_name_matching') do
          contracts = subject.search('Assinatura')

          expect(contracts).not_to be_empty
          contracts.each do |contract|
            expect(contract).to be_a entity_klass
            expect(contract.name).to match /Assinatura/
          end
        end
      end
    end

    context 'sending a name with no matches' do
      it 'returns an empty array as result' do
        VCR.use_cassette('/contracts/search/success/no_matches_result') do
          contracts = subject.search('contrato')
          expect(contracts).to be_empty
        end
      end
    end

    context 'providing no name or empty string for search' do
      it 'raises Billimatic::RequestError on empty string search' do
        VCR.use_cassette('/contracts/search/failure/empty_string_name') do
          expect {
            subject.search('')
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 400
          end
        end
      end

      it 'raises Billimatic::RequestError on request without name parameter' do
        VCR.use_cassette('/contracts/search/failure/null_parameter') do
          expect {
            subject.search(nil)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 400
          end
        end
      end
    end
  end
end
