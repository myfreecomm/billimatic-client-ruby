require 'spec_helper'

describe Billimatic::Resources::Person do
  let(:entity_klass) { Billimatic::Entities::Person }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#show' do
    it "raises Billimatic::RequestError with not found status when id isn't found" do
      VCR.use_cassette('/people/show/failure/person_not_found') do
        expect { subject.show(1_000_000) }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it "raises Billimatic::RequestError with not found status when trying to find person from another account" do
      VCR.use_cassette('/people/show/failure/another_account_person_not_found') do
        expect { subject.show(6) }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'returns a person entity' do
      VCR.use_cassette('/people/show/success') do
        person = subject.show(3)

        expect(person).to be_a entity_klass
        expect(person.id).to eql 3
      end
    end
  end

  describe '#search' do
    it 'raises Billimatic::RequestError when :cpf argument is nil' do
      VCR.use_cassette('/people/search/failure/null_argument') do
        expect {
          subject.search(cpf: nil)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'raises Billimatic::RequestError when :cpf argument is an empty string' do
      VCR.use_cassette('/people/search/failure/empty_string_argument') do
        expect {
          subject.search(cpf: "")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'returns a list of people with matching unformatted document' do
      VCR.use_cassette('/people/search/success/unformatted_document') do
        result = subject.search(cpf: "64080148798")

        expect(result).not_to be_empty
        result.each do |person|
          expect(person).to be_a entity_klass
          expect(person.cpf).to eql "64080148798"
        end
      end
    end

    it 'returns a list of people with matching formatted document' do
      VCR.use_cassette('/people/search/success/formatted_document') do
        result = subject.search(cpf: "640.801.487-98")

        expect(result).not_to be_empty
        result.each do |person|
          expect(person).to be_a entity_klass
          expect(person.cpf).to eql "64080148798"
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
              cpf: "717.810.625-52",
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
            subject.update(1592, name: "")
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
            expect(error.body['errors']).to have_key 'name'
          end
        end
      end

      it 'successfully updates person' do
        VCR.use_cassette('people/update/success') do
          person = subject.update(1592, email: "teste-pessoa-fisica@teste.com.br")

          expect(person).to be_a entity_klass
          expect(person.email).to eql "teste-pessoa-fisica@teste.com.br"
        end
      end
    end

    describe '#destroy' do
      it "raises Billimatic::RequestError if person wasn't found" do
        VCR.use_cassette('people/destroy/failure/person_not_found') do
          expect {
            subject.destroy(25000)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 404
          end
        end
      end

      it 'raises Billimatic::RequestError if person cannot be deleted' do
        VCR.use_cassette('people/destroy/failure/person_with_attached_contracts') do
          expect {
            subject.destroy(1194)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
            expect(error.body['errors']).not_to be_empty
          end
        end
      end

      it 'successfully deletes a person' do
        VCR.use_cassette('people/destroy/success') do
          expect(subject.destroy(1592)).to be true
        end
      end
    end
  end
end
