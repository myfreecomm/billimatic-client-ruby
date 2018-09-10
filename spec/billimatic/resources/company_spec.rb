require 'spec_helper'

describe Billimatic::Resources::Company do
  let(:token) { 'bfe97f701f615edf41587cbd59d6a0e8' } # user login my_favorite_billimatic_user@mailinator.com, passw: 123456
  let(:entity_klass) { Billimatic::Entities::Company }
  let(:http) { Billimatic::Http.new(token) }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#list' do
    before do
      Billimatic.configuration.host = "http://localhost:3000"
      Typhoeus::Expectation.clear
      @http = Billimatic::Http.new('5d09f5c3dc8df35e225ad074b66f47e0')
    end

    subject { described_class.new(@http) }

    it 'returns all companies for an account' do
      VCR.use_cassette('/companies/list/success/all_companies') do
        result = subject.list

        expect(result).not_to be_empty
        expect(result.count).to eql 32

        company = result.first
        expect(company).to be_a(entity_klass)
      end
    end
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

  describe '#show' do
    it "raises Billimatic::RequestError with not found status when id isn't found" do
      VCR.use_cassette('/companies/show/failure/company_not_found') do
        expect { subject.show(520) }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it "raises Billimatic::RequestError with not found status when id is of an organization" do
      VCR.use_cassette('/companies/show/failure/organization_not_found') do
        expect { subject.show(1840) }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'returns a company entity' do
      VCR.use_cassette('/companies/show/success') do
        company = subject.show(578)

        expect(company).to be_a entity_klass
        expect(company.id). to eql 578
      end
    end
  end

  describe '#create' do
    let(:params) do
      {
        name: 'Acme Inc',
        cnpj: '46.181.656/0001-59',
        company_name: 'Acme Incorporated',
        address: 'Rua Tal',
        number: '1337',
        complement: 'apto 42',
        district: 'Centro',
        zipcode: '22290080', # always unformatted
        city: 'Rio de Janeiro',
        state: 'RJ',
        ibge_code: '12345',
        contacts: 'foo@bar.com, spam@eggs.co.uk',
        billing_contacts: 'baz@bambam.com.br',
        comments: 'Algum comentário'
      }
    end
    it 'creates a new company' do
      VCR.use_cassette('companies/create/success') do
        company = subject.create(params)
        expect(company).to be_a(entity_klass)
        expect(company.id).to_not be_nil
        expect(company.cnpj).to eq(params[:cnpj])
      end
    end
    it 'raises an error if validation fails' do
      params[:zipcode] = '22290-080' # will fail validation
      VCR.use_cassette('companies/create/failure_validation') do
        expect { subject.create(params) }.to raise_error(
          Billimatic::RequestError) do |error|
            expect(error.code).to eq(422)
            expect(error.body['errors']['cnpj']).to eq(['já está em uso'])
            expect(error.body['errors']['zipcode']).
              to eq(['Por favor digite um CEP válido.'])
          end
      end
    end
  end

  describe '#update' do
    let(:id) { 571 } # ID of the company created on the #create test above
    let(:params) do
      {address: 'Outra Rua', number: '999'}
    end
    it 'updates an existing company' do
      VCR.use_cassette('companies/update/success') do
        company = subject.update(id, params)
        expect(company).to be_a(entity_klass)
        expect(company.id).to eq(id)
        expect(company.address).to eq(params[:address])
        expect(company.number).to eq(params[:number])
        expect(company.name).to eq('Acme Inc') # not changed
      end
    end
    it 'raises an error if validation fails' do
      params[:zipcode] = '22290-080' # will fail validation
      VCR.use_cassette('companies/update/failure_validation') do
        expect { subject.update(id, params) }.to raise_error(
          Billimatic::RequestError) do |error|
            expect(error.code).to eq(422)
            expect(error.body['errors']['zipcode']).
              to eq(['Por favor digite um CEP válido.'])
          end
      end
    end
    it 'raises an error if the company does not exist' do
      VCR.use_cassette('companies/update/failure_not_found') do
        expect { subject.update(id + 1, params) }.to raise_error(
          Billimatic::RequestError) { |error| expect(error.code).to eq(404) }
      end
    end
  end

  describe '#destroy' do
    let(:id) { 571 } # ID of the company created on the #create test above
    it 'deletes an existing company and returns true' do
      VCR.use_cassette('companies/destroy/success') do
        result = subject.destroy(id)
        expect(result).to be_truthy
      end
    end
    it 'raises an error if the company does not exist' do
      VCR.use_cassette('companies/destroy/failure_not_found') do
        expect { subject.destroy(id + 1) }.to raise_error(
          Billimatic::RequestError) { |error| expect(error.code).to eq(404) }
      end
    end
  end
end
