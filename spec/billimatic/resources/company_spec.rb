require 'spec_helper'

describe Billimatic::Resources::Company do
  let(:token) { 'bfe97f701f615edf41587cbd59d6a0e8' } # user login my_favorite_billimatic_user@mailinator.com, passw: 123456
  let(:entity_klass) { Billimatic::Entities::Company }
  let(:http) { Billimatic::Http.new(token) }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#search' do
    it 'returns an array of companies' do
      VCR.use_cassette('companies/search/success') do
        cnpj = '81.644.331/0001-66'
        companies = subject.search(cnpj)
        expect(companies).to be_a(Array)
        companies.each do |company|
          expect(company).to be_a(entity_klass)
          expect(company.cnpj).to eq(cnpj)
        end
      end
    end
    it 'allows non-formatted CNPJs' do
      VCR.use_cassette('companies/search/success_unformatted') do
        cnpj = '81.644.331/0001-66'
        unformatted_cnpj = cnpj.gsub(/[\.\/\-]/, '') # only numbers
        companies = subject.search(unformatted_cnpj)
        expect(companies).to be_a(Array)
        companies.each do |company|
          expect(company).to be_a(entity_klass)
          expect(company.cnpj).to eq(cnpj)
        end
      end
    end
    it 'returns an empty array if no match is found' do
      VCR.use_cassette('companies/search/success_empty') do
        cnpj = '45.368.637/0001-73'
        companies = subject.search(cnpj)
        expect(companies).to be_a(Array)
        expect(companies).to be_empty
      end
    end
    it 'requires a CNPJ to search' do
      expect { subject.search }.to raise_error(ArgumentError)
      VCR.use_cassette('companies/search/error_nil_cnpj') do
        expect { subject.search(nil) }.to raise_error(
          Billimatic::RequestError) { |error| expect(error.code).to eq(400) }
      end
      VCR.use_cassette('companies/search/error_empty_cnpj') do
        expect { subject.search('') }.to raise_error(
          Billimatic::RequestError) { |error| expect(error.code).to eq(400) }
      end
    end
  end

end
