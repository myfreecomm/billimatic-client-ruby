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
          contract_id: 8818,
          issue_date_from: '10-05-2017',
          issue_date_to: '10-08-2017'
        )

        expect(invoices).not_to be_empty
        invoices.each do |invoice|
          expect(invoice).to be_a entity_klass
          expect(invoice.management_type).to eql 'manual'
          expect(invoice.contract_id).to eql 8818
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

  describe '#show' do
    it 'returns not found when contract is not found' do
      VCR.use_cassette("/invoices/show/failure/contract_not_found") do
        expect {
          subject.show(127262, contract_id: 10000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'returns not found when invoice is not found' do
      VCR.use_cassette("/invoices/show/failure/invoice_not_found") do
        expect {
          subject.show(12, contract_id: 6666)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'returns invoice successfully' do
      VCR.use_cassette("/invoices/show/success") do
        invoice = subject.show(168138, contract_id: 8818)

        expect(invoice).to be_a entity_klass
        expect(invoice.id).to eql 168138
        expect(invoice.management_type).to eql 'manual'
        expect(invoice.contract_id).to eql 8818
      end
    end

    context 'when approval_status' do
      it 'returns an invoice with approval_status is blocked' do
        VCR.use_cassette("/invoices/show/success/approval_status_blocked") do
          invoice = subject.show(167742, contract_id: 6666)

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql(6666)
          expect(invoice.approval_status).to eql('blocked')
        end
      end

      it 'returns an invoice with approval_status is aproved' do
        VCR.use_cassette("/invoices/show/success/approval_status_aproved") do
          invoice = subject.show(168426, contract_id: 6666)

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql(6666)
          expect(invoice.approval_status).to eql('approved')
        end
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
        invoice_attributes[:services] = [
                                          {
                                            service_item_id: 57,
                                            description: 'Descrição teste',
                                            units: 2,
                                            unit_value: 100
                                          }
                                        ]

        invoice = subject.create(invoice_attributes, contract_id: 6666)

        expect(invoice).to be_a entity_klass
        expect(invoice.contract_id).to eql 6666
        expect(invoice.gross_value).to eql 200.0
        expect(invoice.services).not_to be_empty
        expect(invoice.services.first.description).to eql('Descrição teste')
      end
    end

    context 'when invoice is already blocked' do
      let(:http) { Billimatic::Http.new('6995d1ad4f1ed7465bb122ee759a7aa6') }

      subject { described_class.new(http) }

      before { Billimatic.configuration.host = 'http://localhost:3000' }

      it 'creates an already blocked invoice' do
        VCR.use_cassette('/invoices/create/success/invoice_already_blocked') do
          invoice = subject.create(
            invoice_attributes.merge(
              approval_status: 'blocked',
              receivables: [{ due_date: Date.today }]
            ), contract_id: 44
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql(44)
          expect(invoice.receivables).not_to be_empty
          expect(invoice.approval_status).to eql('blocked')
        end
      end
    end

    context 'when invoice set management_type' do
      it 'creates an invoice with automatic management' do
        VCR.use_cassette('/invoices/create/success/management_automatic') do
          invoice = subject.create(
            invoice_attributes.merge(
              management_type: 'automatic',
              days_until_automatic_nfe_emission: 3,
              automatic_email_template_id: 1
            ),
            contract_id: 6666
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql(6666)
          expect(invoice.gross_value).to eql(100.0)
          expect(invoice.management_type).to eql('automatic')
          expect(invoice.days_until_automatic_nfe_emission).to eql(3)
          expect(invoice.automatic_email_template_id).to eql(1)
          expect(invoice.receivables).not_to be_empty
        end
      end

      it 'creates an invoice with manual management' do
        VCR.use_cassette('/invoices/create/success/management_manual') do
          invoice = subject.create(
            invoice_attributes.merge(
              management_type: 'manual',
              days_until_automatic_nfe_emission: 0,
              automatic_email_template_id: 0
            ),
            contract_id: 6666
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql 6666
          expect(invoice.gross_value).to eql 100.0
          expect(invoice.management_type).to eql('manual')
          expect(invoice.days_until_automatic_nfe_emission).to eql(0)
          expect(invoice.automatic_email_template_id).to eql(0)
          expect(invoice.receivables).not_to be_empty
        end
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
          { services: [ { service_item_id: 31, description: 'Descrição teste', units: 2, unit_value: 100.0 } ] },
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

    context 'when invoice is already blocked' do
      let(:http) { Billimatic::Http.new('6995d1ad4f1ed7465bb122ee759a7aa6') }

      subject { described_class.new(http) }

      before { Billimatic.configuration.host = 'http://localhost:3000' }

      it "can't change invoice approval_status to blocked" do
        VCR.use_cassette('/invoices/update/failure/contract_approved_to_blocked') do
          invoice = subject.update(
            3568, {approval_status: 'blocked'}, contract_id: 44
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql 44
          expect(invoice.approval_status).to eql('approved')
        end
      end

      it "can't change invoice approval_status to approved" do
        VCR.use_cassette('/invoices/update/failure/contract_blocked_to_approved') do
          invoice = subject.update(
            3628, {approval_status: 'approved'}, contract_id: 44
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql 44
          expect(invoice.approval_status).to eql('blocked')
        end
      end
    end

    context 'when change management_type of invoice' do
      it 'updates an invoice with manual management' do
        VCR.use_cassette('/invoices/update/success/management_manual') do
          invoice = subject.update(
            168537, {
              management_type: 'manual',
              days_until_automatic_nfe_emission: 0,
              automatic_email_template_id: 0
            },
            contract_id: 6666
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql 6666
          expect(invoice.gross_value).to eql 100.0
          expect(invoice.management_type).to eql('manual')
          expect(invoice.days_until_automatic_nfe_emission).to eql(0)
          expect(invoice.automatic_email_template_id).to eql(0)
          expect(invoice.receivables).not_to be_empty
        end
      end

      it 'updates an invoice with automatic management' do
        VCR.use_cassette('/invoices/update/success/management_automatic') do
          invoice = subject.update(
            168538, {
              management_type: 'automatic',
              days_until_automatic_nfe_emission: 3,
              automatic_email_template_id: 1
            },
            contract_id: 6666
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql(6666)
          expect(invoice.management_type).to eql('automatic')
          expect(invoice.days_until_automatic_nfe_emission).to eql(3)
          expect(invoice.automatic_email_template_id).to eql(1)
          expect(invoice.receivables).not_to be_empty
        end
      end

      it 'updates only template_id of invoice' do
        VCR.use_cassette('/invoices/update/success/management_template') do
          invoice = subject.update(
            168538, { automatic_email_template_id: 2 }, contract_id: 6666
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.contract_id).to eql(6666)
          expect(invoice.management_type).to eql('automatic')
          expect(invoice.days_until_automatic_nfe_emission).to eql(3)
          expect(invoice.automatic_email_template_id).to eql(2)
          expect(invoice.receivables).not_to be_empty
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
        expect(subject.destroy(168538, contract_id: 6666)).to be true
      end
    end
  end

  describe '#block' do
    context 'when success' do
      it 'successfully block an invoice' do
        VCR.use_cassette('/invoices/block/success') do
          invoice = subject.block(168431, contract_id: 6666)

          expect(invoice).to be_truthy
          expect(invoice).to be_a(entity_klass)
          expect(invoice.approval_status).to eql('blocked')
        end
      end
    end

    context 'when error' do
      it 'raises Billimatic::RequestError when invoice not found' do
        VCR.use_cassette('/invoices/block/failure/invoice_not_found') do
          expect {
            subject.block(8888, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(404)
          end
        end
      end

      it 'raises Billimatic::RequestError when contract not found' do
        VCR.use_cassette('/invoices/block/failure/contract_not_found') do
          expect {
            subject.block(168431, contract_id: 50)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(404)
          end
        end
      end

      it 'raises Billimatic::RequestError when invoice is already blocked' do
        VCR.use_cassette('/invoices/block/failure/invoice_already_blocked') do
          expect {
            subject.block(168431, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end

      it 'raises Billimatic::RequestError when invoice is not to emit' do
        VCR.use_cassette('/invoices/block/failure/invoice_is_not_to_emit') do
          expect {
            subject.block(168431, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end
    end
  end

  describe '#approve' do
    context 'when success' do
      it 'successfully approve an invoice' do
        VCR.use_cassette('/invoices/approve/success') do
          response = subject.approve(168431, contract_id: 6666)

          expect(response).to be_a(entity_klass)
          expect(response.approval_status).to eql('approved')
        end
      end
    end

    context 'when error' do
      it 'raises Billimatic::RequestError when invoice not found' do
        VCR.use_cassette('/invoices/approve/failure/invoice_not_found') do
          expect {
            subject.approve(8888, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(404)
          end
        end
      end

      it 'raises Billimatic::RequestError when contract not found' do
        VCR.use_cassette('/invoices/approve/failure/contract_not_found') do
          expect {
            subject.approve(168431, contract_id: 50)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(404)
          end
        end
      end

      it 'raises Billimatic::RequestError when invoice is already approved' do
        VCR.use_cassette('/invoices/approve/failure/invoice_already_approved') do
          expect {
            subject.approve(168431, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end

      it 'raises Billimatic::RequestError when invoice is not to emit' do
        VCR.use_cassette('/invoices/approve/failure/invoice_is_not_to_emit') do
          expect {
            subject.approve(168431, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end
    end
  end
end
