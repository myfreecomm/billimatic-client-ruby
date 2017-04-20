require 'spec_helper'

describe Billimatic::Resources::InvoiceRule do
  let(:entity_klass) { Billimatic::Entities::InvoiceRule }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#create' do
    let(:invoice_rule_params) do
      {
        additional_information: {
          title: "REGRA",
          init_date: "02/09/2016",
          month_quantity: 6
        },
        gross_value: 100.0,
        description: "Faturamento",
        nfe_body:    "$DESCRICAO",
        charge_type: "fixed_day",
        receivables_additional_information: {
          day_number: 23
        }
      }
    end

    it "raises Billimatic::RequestError when contract isn't found" do
      VCR.use_cassette('invoice_rules/create/contract_not_found_failure') do
        expect {
          subject.create(invoice_rule_params, contract_id: 1000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError when invoice_rule is invalid' do
      VCR.use_cassette('invoice_rules/create/invalid_rule_failure') do
        expect {
          subject.create({ description: '' }, contract_id: 219)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'creates an invoice_rule without scheduled update, without parcels and for fixed day' do
      VCR.use_cassette('invoice_rules/create/success/without_supdate_parcels_for_fixed_day') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 6666)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_update).to be_nil
        expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
        expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
      end
    end

    it 'creates an invoice_rule without scheduled update, without parcels and for last day of month' do
      invoice_rule_params[:charge_type] = 'last_day_of_month'
      invoice_rule_params[:receivables_additional_information][:day_number] = nil

      VCR.use_cassette('invoice_rules/create/success/without_supdate_parcels_for_last_day_of_month') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 6666)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_update).to be_nil
        expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
        expect(invoice_rule.receivables_additional_information['day_number']).to be_nil
      end
    end

    it 'creates an invoice_rule without scheduled update, without parcels and for day quantity' do
      invoice_rule_params[:charge_type] = 'day_quantity'
      invoice_rule_params[:receivables_additional_information][:day_number] = nil
      invoice_rule_params[:receivables_additional_information][:day_quantity] = 3

      VCR.use_cassette('invoice_rules/create/success/without_supdate_parcels_for_day_quantity') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 6666)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_update).to be_nil
        expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
        expect(invoice_rule.receivables_additional_information['day_number']).to be_nil
        expect(invoice_rule.receivables_additional_information['day_quantity']).to eql 3
      end
    end

    it 'creates an invoice_rule without scheduled update, without parcels and for fixed day and month' do
      invoice_rule_params[:charge_type] = 'fixed_day_and_month_quantity'
      invoice_rule_params[:receivables_additional_information][:day_number] = 3
      invoice_rule_params[:receivables_additional_information][:month_quantity] = 2

      VCR.use_cassette('invoice_rules/create/success/without_supdate_parcels_for_fixed_day_and_month_quantity') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 6666)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_update).to be_nil
        expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
        expect(invoice_rule.receivables_additional_information['day_number']).to eql 3
        expect(invoice_rule.receivables_additional_information['month_quantity']).to eql 2
      end
    end

    it 'creates an invoice_rule without scheduled update, with 3 parcels and for fixed day' do
      invoice_rule_params[:receivables_additional_information][:parcel_number] = 3

      VCR.use_cassette('invoice_rules/create/success/without_supdate_with_parcels_for_fixed_day') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 6666)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_update).to be_nil
        expect(invoice_rule.receivables_additional_information['parcel_number']).to eql 3
        expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
      end
    end

    it 'creates an invoice_rule with scheduled update, without parcels and for fixed day' do
      invoice_rule_params[:scheduled_update] = {
        will_be_created: 'true',
        price_index: 'ipca',
        init_date: '02/10/2016',
        month_quantity: 12,
        days_until_update: 5
      }

      VCR.use_cassette('invoice_rules/create/success/with_supdate_without_parcels_for_fixed_day') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 6666)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_update).not_to be_nil
        expect(invoice_rule.scheduled_update['init_date']).to eql '2016-10-02'
        expect(invoice_rule.scheduled_update['remind_at']).to eql '2016-09-27'
        expect(invoice_rule.scheduled_update['month_quantity']).to eql 12
        expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
      end
    end

    context 'when invoice_rule set management_type' do
      let(:http) { Billimatic::Http.new('6995d1ad4f1ed7465bb122ee759a7aa6') }

      subject { described_class.new(http) }

      before { Billimatic.configuration.host = "localhost:3000" }

      it 'creates an invoice_rule with automatic management' do
        VCR.use_cassette('/invoice_rules/create/success/management_automatic') do
          invoice_rules = subject.create(
            invoice_rule_params.merge(
              management_type: 'automatic',
              days_until_automatic_nfe_emission: 3,
              automatic_email_template_id: 1
            ),
            contract_id: 3
          )

          expect(invoice_rules).to be_a entity_klass
          expect(invoice_rules.gross_value).to eql(100.0)
          expect(invoice_rules.management_type).to eql('automatic')
          expect(invoice_rules.days_until_automatic_nfe_emission).to eql(3)
          expect(invoice_rules.automatic_email_template_id).to eql(1)
        end
      end

      it 'creates an invoice_rules with manual management' do
        VCR.use_cassette('/invoice_rules/create/success/management_manual') do
          invoice_rules = subject.create(
            invoice_rule_params.merge(
              management_type: 'manual',
              days_until_automatic_nfe_emission: 0,
              automatic_email_template_id: 0
            ),
            contract_id: 3
          )

          expect(invoice_rules).to be_a entity_klass
          expect(invoice_rules.gross_value).to eql 100.0
          expect(invoice_rules.management_type).to eql('manual')
          expect(invoice_rules.days_until_automatic_nfe_emission).to eql(0)
          expect(invoice_rules.automatic_email_template_id).to eql(0)
        end
      end
    end

    context 'dealing with services' do
      it 'creates services for invoice_rule and calculates its gross value automatically' do
        invoice_rule_params[:services] = [
          {
            service_item_id: 57,
            description: 'Descrição teste',
            units: 2,
            unit_value: 150.0,
            value: 300.0
          }
        ]

        VCR.use_cassette('invoice_rules/create/success/with_services') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 6666)
          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.services).not_to be_empty
          expect(invoice_rule.services.first).to be_a Billimatic::Entities::Service
          expect(invoice_rule.services.first.value).to eql 300.0
          expect(invoice_rule.services.first.description).to eql 'Descrição teste'
          expect(invoice_rule.gross_value).to eql 300.0
        end
      end
    end
  end

  describe '#update' do
    it "raises Billimatic::RequestError if contract isn't found" do
      VCR.use_cassette('invoice_rules/update/contract_not_found_failure') do
        expect {
          subject.update(127194, { description: 'NOVO FATURAMENTO' }, contract_id: 1000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it "raises Billimatic::RequestError if invoice rule isn't found" do
      VCR.use_cassette('invoice_rules/update/rule_not_found_failure') do
        expect {
          subject.update(200000, { description: 'NOVO FATURAMENTO' }, contract_id: 6666)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if invoice_rule is invalid' do
      VCR.use_cassette('invoice_rules/update/invalid_rule_failure') do
        expect {
          subject.update(127194, { description: '' }, contract_id: 6666)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if service to be added is invalid' do
      VCR.use_cassette('invoice_rules/update/invalid_service_to_be_added_failure') do
        expect {
          subject.update(127194, { services: [{ units: '' }] }, contract_id: 6666)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if existing service is invalid' do
      VCR.use_cassette('invoice_rules/update/invalid_existing_service_failure') do
        expect {
          subject.update(127230, { services: [{ id: 183069, units: '' }] }, contract_id: 6666)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if additional information is invalid' do
      VCR.use_cassette('invoice_rules/update/invalid_additional_information_failure') do
        expect {
          subject.update(
            127230,
            { additional_information: { id: 5365, title: '' } },
            contract_id: 6666
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if receivables additional information is invalid' do
      VCR.use_cassette('invoice_rules/update/invalid_receivables_additional_information_failure') do
        expect {
          subject.update(
            127230,
            {
              charge_type: 'fixed_day_and_month_quantity',
              receivables_additional_information: { id: 5356, month_quantity: '' }
            },
            contract_id: 6666
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if new scheduled update is invalid' do
      VCR.use_cassette('invoice_rules/update/invalid_new_scheduled_update_failure') do
        expect {
          subject.update(
            127230,
            {
              scheduled_update: { will_be_created: 'true', month_quantity: '' }
            },
            contract_id: 6666
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if existing scheduled update is invalid' do
      VCR.use_cassette('invoice_rules/update/invalid_existing_scheduled_update_failure') do
        expect {
          subject.update(
            127224,
            {
              scheduled_update: { id: 96, will_be_created: 'true', month_quantity: '' }
            },
            contract_id: 6666
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'updates invoice_rule attributes correctly' do
      VCR.use_cassette('invoice_rules/update/success/rule_attributes') do
        invoice_rule = subject.update(
          144091,
          { gross_value: 300.0, description: 'Faturamento novo' },
          contract_id: 6666
        )

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.description).to eql 'Faturamento novo'
        expect(invoice_rule.gross_value).to eql 300.0
      end
    end

    it 'updates rule additional information' do
      VCR.use_cassette('invoice_rules/update/success/additional_information_atttributes') do
        invoice_rule = subject.update(
          127230,
          { additional_information: { id: 5365, title: 'NOVA REGRA', month_quantity: 1 } },
          contract_id: 6666
        )

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.additional_information['title']).to eql 'NOVA REGRA'
        expect(invoice_rule.additional_information['month_quantity']).to eql 1
      end
    end

    it 'updates rule receivables additional information' do
      VCR.use_cassette('invoice_rules/update/success/receivables_additional_information_atttributes') do
        invoice_rule = subject.update(
          127230,
          {
            receivables_additional_information: {
              id: 5356, day_number: 25, parcel_number: 2
            }
          },
          contract_id: 6666
        )

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.receivables_additional_information['day_number']).to eql 25
        expect(invoice_rule.receivables_additional_information['parcel_number']).to eql 2
      end
    end

    it 'updates rule creating scheduled update' do
      VCR.use_cassette('invoice_rules/update/success/new_scheduled_update') do
        invoice_rule = subject.update(
          127224,
          {
            scheduled_update: {
              will_be_created: 'true',
              price_index: 'ipca',
              init_date: '02/10/2016',
              month_quantity: 12,
              days_until_update: 5
            }
          },
          contract_id: 6666
        )

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_update).not_to be_nil
        expect(invoice_rule.scheduled_update['execution_date']).to eql '2016-10-02'
        expect(invoice_rule.scheduled_update['remind_at']).to eql '2016-09-27'
      end
    end

    it 'updates rule existing scheduled update' do
      VCR.use_cassette('invoice_rules/update/success/existing_scheduled_update') do
        invoice_rule = subject.update(
          127224,
          {
            scheduled_update: {
              id: 99,
              will_be_created: 'true',
              price_index: 'igpm',
              month_quantity: 1,
              days_until_update: 2
            }
          },
          contract_id: 6666
        )

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_update['execution_date']).to eql '2016-10-02'
        expect(invoice_rule.scheduled_update['remind_at']).to eql '2016-09-30'
      end
    end

    it 'updates rule with services and calculates its gross_value automatically' do
      VCR.use_cassette('invoice_rules/update/success/new_services') do
        invoice_rule = subject.update(
          167722,
          {
            services: [
              {
                service_item_id: 57,
                description: 'Descrição atualizada',
                units: 2,
                unit_value: 100.0,
                value: 200.0
              }
            ]
          },
          contract_id: 8126
        )

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.services).not_to be_empty
        expect(invoice_rule.services.first.value).to eql 200.0
        expect(invoice_rule.services.first.description).to eql 'Descrição atualizada'
        expect(invoice_rule.gross_value).to eql 200.0
      end
    end

    it "updates rule's existing services and calculates its gross_value automatically" do
      VCR.use_cassette('invoice_rules/update/success/existing_services') do
        invoice_rule = subject.update(
          167722,
          {
            services: [
              {
                id: 226324,
                service_item_id: 57,
                description: 'Descrição atualizada',
                units: 1,
                unit_value: 200.0,
                value: 200.0
              }
            ]
          },
          contract_id: 8126
        )

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.services).not_to be_empty
        expect(invoice_rule.services.first.value).to eql 200.0
        expect(invoice_rule.services.first.description).to eql 'Descrição atualizada'
        expect(invoice_rule.gross_value).to eql 400.0
      end
    end


    context 'when change management_type of invoice_rules' do
      let(:http) { Billimatic::Http.new('6995d1ad4f1ed7465bb122ee759a7aa6') }

      subject { described_class.new(http) }

      before { Billimatic.configuration.host = "localhost:3000" }

      it 'updates an invoice_rules with manual management' do
        VCR.use_cassette('/invoice_rules/update/success/management_manual') do
          invoice_rules = subject.update(
            334, {
              management_type: 'manual',
              days_until_automatic_nfe_emission: 0,
              automatic_email_template_id: 0
            },
            contract_id: 3
          )

          expect(invoice_rules).to be_a entity_klass
          expect(invoice_rules.gross_value).to eql 100.0
          expect(invoice_rules.management_type).to eql('manual')
          expect(invoice_rules.days_until_automatic_nfe_emission).to eql(0)
          expect(invoice_rules.automatic_email_template_id).to eql(0)
        end
      end

      it 'updates an invoice_rules with automatic management' do
        VCR.use_cassette('/invoice_rules/update/success/management_automatic') do
          invoice = subject.update(
            340, {
              management_type: 'automatic',
              days_until_automatic_nfe_emission: 5,
              automatic_email_template_id: 3
            },
            contract_id: 3
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.management_type).to eql('automatic')
          expect(invoice.days_until_automatic_nfe_emission).to eql(5)
          expect(invoice.automatic_email_template_id).to eql(3)
        end
      end

      it 'updates only template_id of invoice_rules' do
        VCR.use_cassette('/invoice_rules/update/success/management_template') do
          invoice = subject.update(
            340, { automatic_email_template_id: 2 }, contract_id: 3
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.management_type).to eql('automatic')
          expect(invoice.days_until_automatic_nfe_emission).to eql(5)
          expect(invoice.automatic_email_template_id).to eql(2)
        end
      end
    end
  end
end
