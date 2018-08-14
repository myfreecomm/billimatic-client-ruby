require 'spec_helper'

describe Billimatic::Resources::Organization do
  let(:entity_klass) { Billimatic::Entities::Organization }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#search' do
    it 'successfully returns an organization matching formatted cnpj' do
      VCR.use_cassette('/organizations/search/success/formatted_cnpj') do
        organization = subject.search(cnpj: "87.667.729/0001-02")
        expect(organization).to be_a entity_klass
        expect(organization.name).to eql "Nova Organização"
        expect(organization.company_name).to eql "Nova Organização LTDA"
        expect(organization.cnpj).to eql "87.667.729/0001-02"
        expect(organization.address).to eql "Rua Baleia"
        expect(organization.number).to eql "857"
        expect(organization.complement).to eql "sl. 542"
        expect(organization.zipcode).to eql "09971000"
        expect(organization.district).to eql "Eldorado"
        expect(organization.city).to eql "Diadema"
        expect(organization.state).to eql "SP"
      end
    end

    it 'successfully returns an organization matching cnpj without any formatting' do
      VCR.use_cassette('/organizations/search/success/unformatted_cnpj') do
        organization = subject.search(cnpj: "25029551000109")
        expect(organization).to be_a entity_klass
        expect(organization.name).to eql "Nova Organização com CNPJ sem formato"
        expect(organization.company_name).to eql "Nova Organização com CNPJ sem formato LTDA"
        expect(organization.cnpj).to eql "25.029.551/0001-09"
        expect(organization.address).to eql "Avenida das Ameixeiras"
        expect(organization.number).to eql "324"
        expect(organization.complement).to eql "9º Andar"
        expect(organization.zipcode).to eql "06654690"
        expect(organization.district).to eql "Jardim Maria Cecília"
        expect(organization.city).to eql "Itapevi"
        expect(organization.state).to eql "SP"
      end
    end

    it 'raises Billimatic::RequestError if cnpj is null' do
      VCR.use_cassette('/organizations/search/failure/null_cnpj') do
        expect {
          subject.search(cnpj: nil)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'raises Billimatic::RequestError if cnpj is an empty string' do
      VCR.use_cassette('/organizations/search/failure/empty_string_cnpj') do
        expect {
          subject.search(cnpj: '')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'raises Billimatic::RequestError if cnpj is not valid' do
      VCR.use_cassette('/organizations/search/failure/invalid_cnpj') do
        expect {
          subject.search(cnpj: 'foo')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if no organizations match the cnpj sent' do
      VCR.use_cassette('/organizations/search/failure/no_organization_matches') do
        expect {
          subject.search(cnpj: '05.784.655/0001-11')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end
  end

  describe '#create' do
    it 'successfully creates an organization with formatted cnpj' do
      VCR.use_cassette('organizations/create/success/formatted_cnpj') do
        organization = subject.create(
          name: "Nova Organização", company_name: 'Nova Organização LTDA.',
          cnpj: "95.532.349/0001-80", address: 'Praça da Sé', number: '123',
          complement: 'conj. 402', zipcode: '01001000', district: 'Sé',
          city: 'São Paulo', state: 'SP'
        )

        expect(organization).to be_a entity_klass
        expect(organization.name).to eql 'Nova Organização'
        expect(organization.company_name).to eql 'Nova Organização LTDA.'
        expect(organization.cnpj).to eql "95.532.349/0001-80"
        expect(organization.address).to eql 'Praça da Sé'
        expect(organization.number).to eql "123"
        expect(organization.complement).to eql "conj. 402"
        expect(organization.zipcode).to eql "01001000"
        expect(organization.district).to eql "Sé"
        expect(organization.city).to eql "São Paulo"
        expect(organization.state).to eql "SP"
      end
    end

    it 'raises Billimatic::RequestError when zipcode is invalid' do
      VCR.use_cassette('organizations/create/failure/invalid_zipcode') do
        expect {
          subject.create(
            name: 'Nova Organização', cnpj: "84.297.903/0001-76",
            zipcode: '123'
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'successfully creates an organization with unformatted cnpj' do
      VCR.use_cassette('organizations/create/success/unformatted_cnpj') do
        organization = subject.create(
          name: "Nova Organização com CNPJ sem formato", cnpj: "25029551000109"
        )

        expect(organization).to be_a entity_klass
        expect(organization.name).to eql 'Nova Organização com CNPJ sem formato'
        expect(organization.cnpj).to eql "25.029.551/0001-09"
      end
    end

    it 'raises Billimatic::RequestError if request is invalid' do
      VCR.use_cassette('organizations/create/failure/invalid_parameters') do
        expect {
          subject.create(cnpj: "87.667.729/0001-02")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError when trying to create a duplicate organization' do
      VCR.use_cassette('organizations/create/failure/duplicate_organization') do
        expect {
          subject.create(name: 'Nova Organização', cnpj: "87.667.729/0001-02")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError when cnpj is invalid' do
      VCR.use_cassette('organizations/create/failure/invalid_cnpj') do
        expect {
          subject.create(name: 'Nova Organização', cnpj: "foo")
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end
  end

  describe '#update' do
    it 'successfully updates an organization' do
      VCR.use_cassette('organizations/update/success/simple_update') do
        organization = subject.update(
          2053, name: 'Organização atualizada',
          company_name: 'Nova Organização LTDA.', address: 'Praça da Sé', number: '123',
          complement: 'conj. 402', zipcode: '01001000', district: 'Sé',
          city: 'São Paulo', state: 'SP'
        )

        expect(organization).to be_a entity_klass
        expect(organization.name).to eql 'Organização atualizada'
        expect(organization.company_name).to eql 'Nova Organização LTDA.'
        expect(organization.address).to eql 'Praça da Sé'
        expect(organization.number).to eql "123"
        expect(organization.complement).to eql "conj. 402"
        expect(organization.zipcode).to eql "01001000"
        expect(organization.district).to eql "Sé"
        expect(organization.city).to eql "São Paulo"
        expect(organization.state).to eql "SP"
      end
    end

    it 'raises Billimatic::RequestError if zipcode is invalid' do
      VCR.use_cassette('organizations/update/failure/invalid_zipcode') do
        expect {
          subject.update(2053, zipcode: '1234')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'successfully changes organization cnpj for a valid one' do
      VCR.use_cassette('organizations/update/success/new_valid_cnpj') do
        organization = subject.update(1839, cnpj: '12.325.676/0001-34')
        expect(organization).to be_a entity_klass
        expect(organization.cnpj).to eql '12.325.676/0001-34'
      end
    end

    it 'raises Billimatic::RequestError if organization is not found' do
      VCR.use_cassette('organizations/update/failure/organization_not_found') do
        expect {
          subject.update(2000, name: 'Updated Organization')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if name is invalid' do
      VCR.use_cassette('organizations/update/failure/invalid_parameter') do
        expect {
          subject.update(1839, name: '')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if cnpj is invalid' do
      VCR.use_cassette('organizations/update/failure/invalid_cnpj') do
        expect {
          subject.update(1839, cnpj: '123456')
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end
  end

  describe '#destroy' do
    it 'successfully deletes an organization' do
      VCR.use_cassette('organizations/destroy/success') do
        expect(subject.destroy(1839)).to be true
      end
    end

    it 'raises Billimatic::RequestError if organization is not found' do
      VCR.use_cassette('organizations/destroy/failure/organization_not_found') do
        expect {
          subject.destroy(2000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if organization has contracts attached' do
      VCR.use_cassette('organizations/destroy/failure/organization_with_contracts') do
        expect {
          subject.destroy(1840)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end
  end
end
