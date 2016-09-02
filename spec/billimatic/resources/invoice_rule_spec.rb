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

    context 'dealing with services' do
      it 'creates services for invoice_rule and calculates its gross value automatically' do
        invoice_rule_params[:services] = [
          { service_item_id: 1, units: 2, unit_value: 150.0, value: 300.0 }
        ]

        VCR.use_cassette('invoice_rules/create/success/with_services') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 6666)

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.services).not_to be_empty
          expect(invoice_rule.services.first).to be_a Billimatic::Entities::Service
          expect(invoice_rule.services.first.value).to eql 300.0
          expect(invoice_rule.gross_value).to eql 300.0
        end
      end
    end
  end
end
