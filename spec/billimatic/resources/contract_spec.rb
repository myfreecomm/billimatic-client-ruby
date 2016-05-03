require 'spec_helper'

describe Billimatic::Resources::Contract do
  let(:entity_klass) { Billimatic::Entities::Contract }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#show :token' do
    it 'returns the contract that has the token attached' do
      VCR.use_cassette('contracts/show_by_token/success') do
        contract = subject.show(token: 'f7e385a902a9f626addacdcccc90f10e')

        expect(contract).to be_a entity_klass
      end
    end

    it 'returns an error if contract is not found with the given token' do
      VCR.use_cassette('contracts/show_by_token/failure') do
        expect {
          subject.show(token: 'foo123')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end
end
