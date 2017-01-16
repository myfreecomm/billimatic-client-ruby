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

  describe '#create' do
    context 'unsuccessful requests' do
      it 'raises Billimatic::RequestError when there are missing attributes on request' do
        VCR.use_cassette('/people/create/failure/missing_attributes') do
          expect {
            subject.create(name: "Person")
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
            expect(error.body['errors']).to have_key 'cpf'
          end
        end
      end

      it 'raises Billimatic::RequestError when tries to create a duplicated person' do
        VCR.use_cassette('/people/create/failure/duplicated') do
          expect {
            subject.create(
              name: "Pessoa Física 2",
              cpf: "048.145.157-90",
              email: "foo@bar.com"
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
            expect(error.body['errors']).to have_key 'cpf'
          end
        end
      end

      it 'raises Billimatic::RequestError when uses invalid document' do
        VCR.use_cassette('/people/create/failure/invalid_document') do
          expect {
            subject.create(
              name: "Nova Pessoa",
              cpf: "foobar",
              email: "foo@bar.com"
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
            expect(error.body['errors']).to have_key 'cpf'
          end
        end
      end

      it 'raises Billimatic::RequestError when uses invalid zipcode' do
        VCR.use_cassette('/people/create/failure/invalid_zipcode') do
          expect {
            subject.create(
              name: "Nova Pessoa",
              cpf: "048.145.157-90",
              email: "foo@bar.com",
              zipcode: "123"
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
            expect(error.body['errors']).to have_key 'zipcode'
          end
        end
      end

      it 'creates person successfully' do
        VCR.use_cassette('/people/create/success/without_address_with_client_since') do
          person = subject.create(
            name: "Nova Pessoa Teste Client Billimatic",
            cpf: "241.989.473-17",
            email: "teste@pessoa.com.br",
            client_since: "16/01/2017"
          )

          expect(person).to be_a entity_klass
          expect(person.name).to eql "Nova Pessoa Teste Client Billimatic"
          expect(person.cpf).to eql "24198947317"
        end
      end
    end

    describe '#update' do
      it 'raises Billimatic::RequestError on not found status' do
        VCR.use_cassette('people/update/failure/person_not_found') do
          expect {
            subject.update(25000, email: "teste-pessoa-fisica@teste.com.br")
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 404
          end
        end
      end

      it 'raises Billimatic::RequestError when request is invalid' do
        VCR.use_cassette('people/update/failure/invalid_params') do
          expect {
            subject.update(187, name: "")
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
            expect(error.body['errors']).to have_key 'name'
          end
        end
      end

      it 'successfully updates person' do
        VCR.use_cassette('people/update/success') do
          person = subject.update(187, email: "teste-pessoa-fisica@teste.com.br")

          expect(person).to be_a entity_klass
          expect(person.email).to eql "teste-pessoa-fisica@teste.com.br"
        end
      end
    end
  end
end
