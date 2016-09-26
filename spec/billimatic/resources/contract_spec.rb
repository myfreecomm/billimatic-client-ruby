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
          contracts = subject.search(name: 'Prestação de Serviço Um')

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
          contracts = subject.search(name: 'Assinatura')

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
          contracts = subject.search(name: 'contrato')
          expect(contracts).to be_empty
        end
      end
    end

    context 'providing no name or empty string for search' do
      it 'raises Billimatic::RequestError on empty string search' do
        VCR.use_cassette('/contracts/search/failure/empty_string_name') do
          expect {
            subject.search(name: '')
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 400
          end
        end
      end

      it 'raises Billimatic::RequestError on request without name parameter' do
        VCR.use_cassette('/contracts/search/failure/null_parameter') do
          expect {
            subject.search(name: nil)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 400
          end
        end
      end
    end
  end

  describe '#create' do
    let(:contract_attributes) do
      {
        name: "newcontract",
        title: "The new contract",
        supplier_id: 564,
        supplier_type: "Company",
        customer_id: 578,
        customer_type: "Company"
      }
    end

    it 'creates successfully a sale contract with a company as customer' do
      VCR.use_cassette('/contracts/create/success/sale_contract_company_customer') do
        contract = subject.create(contract_attributes)

        expect(contract).to be_a entity_klass
        expect(contract.name).to eql 'newcontract'
        expect(contract.kind).to eql 'sale'
        expect(contract.customer_type).to eql 'Company'
      end
    end

    it 'creates successfuly a sale contract with a person as customer' do
      VCR.use_cassette('/contracts/create/success/sale_contract_person_customer') do
        contract_attributes[:name] = 'Person sale contract'
        contract_attributes[:customer_id] = 1194
        contract_attributes[:customer_type] = 'Person'

        contract = subject.create(contract_attributes)

        expect(contract).to be_a entity_klass
        expect(contract.name).to eql 'Person sale contract'
        expect(contract.kind).to eql 'sale'
        expect(contract.customer_type).to eql 'Person'
      end
    end

    it 'creates successfully a purchase contract with a company as supplier' do
      VCR.use_cassette('/contracts/create/success/purchase_contract_company_supplier') do
        contract_attributes[:name] = 'Company purchase contract'
        contract_attributes[:kind] = 'purchase'
        contract_attributes[:customer_id] = 564
        contract_attributes[:customer_type] = 'Company'
        contract_attributes[:supplier_id] = 578
        contract_attributes[:supplier_type] = 'Company'

        contract = subject.create(contract_attributes)

        expect(contract).to be_a entity_klass
        expect(contract.name).to eql 'Company purchase contract'
        expect(contract.kind).to eql 'purchase'
        expect(contract.supplier_type).to eql 'Company'
      end
    end

    it 'creates successfully a purchase contract with a person as supplier' do
      VCR.use_cassette('/contracts/create/success/purchase_contract_person_supplier') do
        contract_attributes[:name] = 'Person purchase contract'
        contract_attributes[:kind] = 'purchase'
        contract_attributes[:customer_id] = 564
        contract_attributes[:customer_type] = 'Company'
        contract_attributes[:supplier_id] = 1194
        contract_attributes[:supplier_type] = 'Person'

        contract = subject.create(contract_attributes)

        expect(contract).to be_a entity_klass
        expect(contract.name).to eql 'Person purchase contract'
        expect(contract.kind).to eql 'purchase'
        expect(contract.supplier_type).to eql 'Person'
      end
    end

    context 'when some mandatory field is not sent' do
      it 'raises Billimatic::RequestError on Unprocessable Entity status' do
        VCR.use_cassette('/contracts/create/failure/mandatory_fields_not_present') do
          contract_attributes.delete(:name)

          expect {
            subject.create(contract_attributes)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end

    context 'when trying to create a contract with duplicated name' do
      it 'raises Billimatic::RequestError on Unprocessable Entity status' do
        VCR.use_cassette('/contracts/create/failure/duplicate_name_contract') do
          contract_attributes[:name] = 'Prestação de Serviço Um'

          expect {
            subject.create(contract_attributes)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end

    context 'when customer is not found or from another account' do
      it 'raises Billimatic::RequestError on Not Found status' do
        VCR.use_cassette('/contracts/create/failure/customer_not_found') do
          contract_attributes[:customer_id] = 1000

          expect {
            subject.create(contract_attributes)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 404
          end
        end
      end
    end

    context 'when supplier is not found or from another account' do
      it 'raises Billimatic::RequestError on Not Found status' do
        VCR.use_cassette('/contracts/create/failure/supplier_not_found') do
          contract_attributes[:supplier_id] = 10000

          expect {
            subject.create(contract_attributes)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 404
          end
        end
      end
    end

    context 'when is a sale contract' do
      it 'raises Billimatic::RequestError if supplier is not an organization' do
        VCR.use_cassette('/contracts/create/failure/supplier_not_organization') do
          contract_attributes[:supplier_id] = 574

          expect {
            subject.create(contract_attributes)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end

    context 'when is a purchase contract' do
      it 'raises Billimatic::RequestError if customer is not an organization' do
        VCR.use_cassette('/contracts/create/failure/customer_not_organization') do
          contract_attributes[:kind] = 'purchase'
          contract_attributes[:supplier_id] = 574

          expect {
            subject.create(contract_attributes)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end
  end

  describe '#update' do
    it 'correctly updates contract attributes' do
      VCR.use_cassette('/contracts/update/success/contract_attributes') do
        contract = subject.update(7392, name: 'Novo Contrato')

        expect(contract).to be_a entity_klass
        expect(contract.name).to eql 'Novo Contrato'
      end
    end

    context 'when contract is not found' do
      it 'raises Billimatic::RequestError on Not Found status' do
        VCR.use_cassette('/contracts/update/failure/contract_not_found') do
          expect {
            subject.update(1000, name: 'Novo Contrato')
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 404
          end
        end
      end
    end

    context 'when supplier is not found or belongs to another account' do
      it 'raises Billimatic::RequestError on Not Found status' do
        VCR.use_cassette('/contracts/update/failure/supplier_not_found') do
          expect {
            subject.update(7394, name: 'Novo Contrato', supplier_id: 1000)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 404
          end
        end
      end
    end

    context 'when customer is not found or belongs to another account' do
      it 'raises Billimatic::RequestError on Not Found status' do
        VCR.use_cassette('/contracts/update/failure/customer_not_found') do
          expect {
            subject.update(7392, name: 'Novo Contrato', customer_id: 1000)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 404
          end
        end
      end
    end

    context 'when trying to update with invalid attributes' do
      it 'raises Billimatic::RequestError on Unprocessable Entity status' do
        VCR.use_cassette('/contracts/update/failure/invalid_contract_attributes') do
          expect {
            subject.update(7392, name: '')
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end
  end

  describe '#destroy' do
    it 'raises Billimatic::RequestError if contract is not found' do
      VCR.use_cassette('/contracts/destroy/failure/contract_not_found') do
        expect {
          subject.destroy(100000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'correctly deletes a contract' do
      VCR.use_cassette('/contracts/destroy/success') do
        expect(subject.destroy(7392)).to be true
      end
    end
  end
end
