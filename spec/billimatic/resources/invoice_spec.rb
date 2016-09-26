require 'spec_helper'

describe Billimatic::Resources::Invoice do
  let(:entity_klass) { Billimatic::Entities::Invoice }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#search' do
    it 'raises Billimatic::RequestError if contract is not found' do
      VCR.use_cassette('/invoices/search/failure/contract_not_found') do
        expect {
          subject.search(
            contract_id: 7392,
            issue_date_from: '02-05-2016',
            issue_date_to: '03-05-2016'
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if search params are invalid' do
      VCR.use_cassette('/invoices/search/failure/invalid_search_parameters') do
        expect {
          subject.search(
            contract_id: 6666,
            issue_date_from: 'foo',
            issue_date_to: ''
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 400
        end
      end
    end

    it 'returns a collection of invoices matching the desired issue_date range' do
      VCR.use_cassette('/invoices/search/success/issue_date_range_matches') do
        invoices = subject.search(
          contract_id: 6666,
          issue_date_from: '02-05-2015',
          issue_date_to: '03-05-2017'
        )

        expect(invoices).not_to be_empty
        invoices.each do |invoice|
          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql 6666
        end
      end
    end

    it 'returns an empty array if no invoices match the desired range' do
      VCR.use_cassette('/invoices/search/success/no_matches') do
        invoices = subject.search(
          contract_id: 6666,
          issue_date_from: '02-05-2019',
          issue_date_to: '03-05-2020'
        )

        expect(invoices).to be_empty
      end
    end
  end

  describe '#create' do
    let(:invoice_attributes) do
      {
        gross_value: 100.0,
        issue_date: '2016-09-19',
        description: 'FATURAMENTO',
        nfe_body: 'FATURAMENTO',
        receivables: [
          { due_date: '2016-10-01' }
        ]
      }
    end

    it 'creates an invoice with simple attributes' do
      VCR.use_cassette('/invoices/create/success/simple_attributes') do
        invoice = subject.create(invoice_attributes, contract_id: 6666)

        expect(invoice).to be_a entity_klass
        expect(invoice.contract_id).to eql 6666
        expect(invoice.gross_value).to eql 100.0
        expect(invoice.receivables).not_to be_empty
      end
    end

    it 'create an invoice with multiple receivables' do
      VCR.use_cassette('/invoices/create/success/multiple_receivables') do
        invoice_attributes[:receivables] = [
          { due_date: '2016-11-01', value: 70 },
          { due_date: '2016-12-01', value: 30 }
        ]

        invoice = subject.create(invoice_attributes, contract_id: 6666)

        expect(invoice).to be_a entity_klass
        expect(invoice.contract_id).to eql 6666
        expect(invoice.gross_value).to eql 100.0
        expect(invoice.receivables.size).to eql 2
      end
    end

    it 'creates an invoice with services and automatically calculates its gross value' do
      VCR.use_cassette('/invoices/create/success/creation_with_services') do
        invoice_attributes[:services] = [ { service_item_id: 31, units: 2, unit_value: 100 } ]

        invoice = subject.create(invoice_attributes, contract_id: 6666)

        expect(invoice).to be_a entity_klass
        expect(invoice.contract_id).to eql 6666
        expect(invoice.gross_value).to eql 200.0
        expect(invoice.services).not_to be_empty
      end
    end

    context 'when contract is not found' do
      it 'raises Billimatic::RequestError on Not Found status' do
        VCR.use_cassette('/invoices/create/failure/contract_not_found') do
          expect {
            subject.create(invoice_attributes, contract_id: 7392)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 404
          end
        end
      end
    end

    context 'invalid invoice parameters' do
      it 'raises Billimatic::RequestError if invoice is invalid' do
        VCR.use_cassette('/invoices/create/failure/invalid_invoice_parameters') do
          invoice_attributes.delete(:description)

          expect {
            subject.create(invoice_attributes, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'raises Billimatic::RequestError if invoice receivables are invalid' do
        VCR.use_cassette('/invoices/create/failure/invalid_receivables') do
          invoice_attributes.delete(:receivables)
          invoice_attributes[:receivables] = [ { value: 100.0 } ]

          expect {
            subject.create(invoice_attributes, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'raises Billimatic::RequestError if invoice receivables are empty' do
        VCR.use_cassette('/invoices/create/failure/empty_receivables') do
          invoice_attributes.delete(:receivables)

          expect {
            subject.create(invoice_attributes, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'raises Billimatic::RequestError if receivable calculation has errors' do
        VCR.use_cassette('/invoices/create/failure/receivables_calculation_error') do
          invoice_attributes[:receivables] = [ { due_date: '2016-09-21', value: 120.0 } ]

          expect {
            subject.create(invoice_attributes, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'raises Billimatic::RequestError if services are invalid' do
        VCR.use_cassette('/invoices/create/failure/invalid_services') do
          invoice_attributes[:services] = [ { units: '' } ]

          expect {
            subject.create(invoice_attributes, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end
  end

  describe '#update' do
    it 'successfully updates invoice attributes' do
      VCR.use_cassette('/invoices/update/success/invoice_attributes') do
        invoice = subject.update(
          144097,
          { description: 'Novo faturamento' },
          contract_id: 6666
        )

        expect(invoice).to be_a entity_klass
        expect(invoice.description).to eql 'Novo faturamento'
      end
    end

    it 'successfully updates an invoice creating a new receivable' do
      VCR.use_cassette('/invoices/update/success/with_new_receivable') do
        invoice = subject.update(
          144097,
          { receivables: [ { due_date: '2016-11-01' } ] },
          contract_id: 6666
        )

        expect(invoice).to be_a entity_klass
        expect(invoice.receivables.size).to eql 2
      end
    end

    it 'successfully updates an invoice updating a receivable' do
      VCR.use_cassette('/invoices/update/success/updates_receivable') do
        invoice = subject.update(
          144097,
          { receivables: [ { id: 156067, value: 50.0 }, { id: 140252, value: 50.0 } ] },
          contract_id: 6666
        )

        expect(invoice).to be_a entity_klass
        expect(invoice.gross_value).to eql 300.0

        invoice.receivables.each do |receivable|
          expect(receivable.gross_value).to eql 150.0
        end
      end
    end

    it 'successfully updates an invoice deleting a receivable' do
      VCR.use_cassette('/invoices/update/success/deletes_receivable') do
        invoice = subject.update(
          144097,
          { receivables: [ { id: 156067, _destroy: true }, { id: 140252, value: 100.0 } ] },
          contract_id: 6666
        )

        expect(invoice).to be_a entity_klass
        expect(invoice.gross_value).to eql 300.0
        expect(invoice.receivables.size).to eql 1
      end
    end

    it 'successfully updates an invoice creating a service' do
      VCR.use_cassette('/invoices/update/success/creates_service') do
        invoice = subject.update(
          144097,
          { services: [ { service_item_id: 31, units: 2, unit_value: 100.0 } ] },
          contract_id: 6666
        )

        expect(invoice).to be_a entity_klass
        expect(invoice.services).not_to be_empty
        expect(invoice.gross_value).to eql 200.0
      end
    end

    it 'successfully updates an invoice updating its services' do
      VCR.use_cassette('/invoices/update/success/updates_service') do
        invoice = subject.update(
          144097,
          { services: [ { id: 200537, units: 3 } ] },
          contract_id: 6666
        )

        expect(invoice).to be_a entity_klass
        expect(invoice.gross_value).to eql 300.0
      end
    end

    it 'successfully updates an invoice deleting its services' do
      VCR.use_cassette('/invoices/update/success/deletes_service') do
        invoice = subject.update(
          144097,
          { services: [ { id: 200537, _destroy: true } ] },
          contract_id: 6666
        )

        expect(invoice).to be_a entity_klass
        expect(invoice.services).to be_empty
        expect(invoice.gross_value).to eql 300.0
      end
    end

    it 'raises Billimatic::RequestError if contract is not found' do
      VCR.use_cassette('/invoices/update/failure/contract_not_found') do
        expect {
          subject.update(
            144097, { description: "Novo faturamento" }, contract_id: 7392
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if invoice is not found' do
      VCR.use_cassette('/invoices/update/failure/invoice_not_found') do
        expect {
          subject.update(
            200000, { description: 'Novo faturamento' }, contract_id: 6666
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if invoice is invalid' do
      VCR.use_cassette('/invoices/update/failure/invalid_invoice_parameters') do
        expect {
          subject.update(144097, { description: '' }, contract_id: 6666)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if invoice receivables are invalid' do
      VCR.use_cassette('/invoices/update/failure/invalid_receivables') do
        expect {
          subject.update(
            144097, { gross_value: 200.0, receivables: [ { value: 200.0 } ] },
            contract_id: 6666
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if invoice receivables calculation is invalid' do
      VCR.use_cassette('/invoices/update/failure/invalid_receivables_calculation') do
        expect {
          subject.update(
            144097, { gross_value: 200.0, receivables: [ { due_date: '2016-10-01', value: 80.0 } ] },
            contract_id: 6666
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if invoice services are invalid' do
      VCR.use_cassette('/invoices/update/failure/invalid_services') do
        expect {
          subject.update(
            144097, { services: [ { service_item_id: 31 } ] }, contract_id: 6666
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end
  end

  describe '#destroy' do
    it 'raises Billimatic::RequestError if contract is not found' do
      VCR.use_cassette('/invoices/destroy/failure/contract_not_found') do
        expect {
          subject.destroy(144090, contract_id: 7392)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if invoice is not found' do
      VCR.use_cassette('/invoices/destroy/failure/invoice_not_found') do
        expect {
          subject.destroy(200000, contract_id: 6666)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'successfully deletes an invoice' do
      VCR.use_cassette('/invoices/destroy/success') do
        expect(subject.destroy(144090, contract_id: 6666)).to be true
      end
    end
  end
end
