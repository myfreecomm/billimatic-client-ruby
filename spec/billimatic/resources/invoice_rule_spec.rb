require 'spec_helper'

describe Billimatic::Resources::InvoiceRule do
  let(:entity_klass) { Billimatic::Entities::InvoiceRule }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#list' do
    it 'raises Billimatic::RequestError when contract is not found' do
      VCR.use_cassette('/invoice_rules/list/failure/contract_not_found') do
        expect {
          subject.list(contract_id: 50_000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql(404)
        end
      end
    end

    it 'returns collection of invoice rules on contract' do
      VCR.use_cassette('/invoice_rules/list/success/not_empty_collection') do
        result = subject.list(contract_id: 8818)

        expect(result).not_to be_empty

        result.each do |invoice_rule|
          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).to eql 168132
          expect(invoice_rule.contract_id).to eql 8818
        end
      end
    end
  end

  describe '#create' do
    let(:invoice_rule_params) do
      {
        additional_information: {
          title: "REGRA",
          init_date: "02/09/2016",
          period_unit: 0,
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

    context 'using a invoice_template_id' do
      before do
        Billimatic.configuration.host = "http://localhost:3000"
        Typhoeus::Expectation.clear
        @http = Billimatic::Http.new('5d09f5c3dc8df35e225ad074b66f47e0')
      end

      subject { described_class.new(@http) }

      it "raises Billimatic::RequestError when invoice_template isn't found by id" do
        VCR.use_cassette('invoice_rules/create/invoice_template_not_found') do
          expect {
            subject.create(
              {
                invoice_template_id: 10_000,
                additional_information: {
                  title: 'Regra com template não encontrado',
                  init_date: '14/12/2018'
                }
              }, contract_id: 221
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'creates a rule using an invoice template completely filled' do
        VCR.use_cassette('invoice_rules/create/using_complete_invoice_template') do
          result = subject.create(
            {
              invoice_template_id: 14,
              additional_information: {
                title: 'Teste com modelo completo',
                init_date: Date.today
              }
            }, contract_id: 248
          )

          expect(result).to be_a entity_klass
          expect(result.services.count).to eql 2

          services = result.services
          expect(services.map(&:name)).to include 'App', 'Serviço 1'
          expect(services.map(&:units)).to include 1.0, 2.5
          expect(services.map(&:unit_value)).to include 49.9, 5.75
          expect(services.map(&:value)).to include 49.9, 14.38

          expect(result.description).to eql 'teste'
          expect(result.management_type).to eql 'automatic'
          expect(result.automatic_email_template_id).to eql 1
          expect(result.notification_ruler_id).to eql 57
          expect(result.payment_information.payment_method).to eql 'payment_gateway'

          additional_information = result.additional_information
          expect(additional_information['month_quantity']).to eql 12
        end
      end

      it 'creates a rule using an invoice template but changing values' do
        VCR.use_cassette('invoice_rules/create/using_template_with_changed_values') do
          result = subject.create(
            {
              invoice_template_id: 15,
              additional_information: {
                title: 'Regra com serviços',
                init_date: Date.today
              },
              automatic_email_template_id: 1,
              days_until_automatic_nfe_emission: 4,
              receivables_additional_information: {
                parcel_number: nil
              }
            }, contract_id: 221
          )

          expect(result).to be_a entity_klass
          expect(result.services.count).to eql 3

          expect(result.gross_value).to eql 160.05
          expect(result.automatic_email_template_id).to eql 1
          expect(result.days_until_automatic_nfe_emission).to eql 4
          expect(result.receivables_additional_information['parcel_number']).to be_nil

          services = result.services
          expect(services.map(&:name)).to include 'App', 'Serviço 1', 'Serviço 9'
          expect(services.map(&:units)).to include 1.0, 2.0, 3.5
          expect(services.map(&:unit_value)).to include 59.9, 32.75, 9.9
          expect(services.map(&:value)).to include 59.9, 65.5, 34.65
        end
      end

      it 'creates a rule using an incomplete template' do
        VCR.use_cassette('invoice_rules/create/using_an_incomplete_template') do
          result = subject.create(
            {
              invoice_template_id: 16,
              additional_information: {
                title: 'Regra por template incompleto',
                init_date: Date.today
              },
              receivables_additional_information: {
                day_quantity: 7,
                parcel_number: 2
              },
              gross_value: 79.5,
              myfinance_sale_account_id: 35,
              myfinance_sale_account_name: 'Boletos'
            }, contract_id: 221
          )

          expect(result).to be_a entity_klass
          expect(result.gross_value).to eql 79.5
          expect(result.myfinance_sale_account_id).to eql 35
          expect(result.myfinance_sale_account_name).to eql 'Boletos'
          expect(result.receivables_additional_information['day_quantity']).to eql 7
          expect(result.receivables_additional_information['only_business_days']).to be true
          expect(result.receivables_additional_information['parcel_number']).to eql 2
        end
      end
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
        invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_updates).to be_empty
        expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
        expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
      end
    end

    it 'creates an invoice_rule without scheduled update, without parcels and for last day of month' do
      invoice_rule_params[:charge_type] = 'last_day_of_month'
      invoice_rule_params[:receivables_additional_information][:day_number] = nil

      VCR.use_cassette('invoice_rules/create/success/without_supdate_parcels_for_last_day_of_month') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_updates).to be_empty
        expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
        expect(invoice_rule.receivables_additional_information['day_number']).to be_nil
      end
    end

    it 'creates an invoice_rule without scheduled update, without parcels and for day quantity' do
      invoice_rule_params[:charge_type] = 'day_quantity'
      invoice_rule_params[:receivables_additional_information][:day_number] = nil
      invoice_rule_params[:receivables_additional_information][:day_quantity] = 3

      VCR.use_cassette('invoice_rules/create/success/without_supdate_parcels_for_day_quantity') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_updates).to be_empty
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
        invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_updates).to be_empty
        expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
        expect(invoice_rule.receivables_additional_information['day_number']).to eql 3
        expect(invoice_rule.receivables_additional_information['month_quantity']).to eql 2
      end
    end

    context 'when period_unit is weekly' do
      it "is not valid if periodicity is greater than one year" do
        invoice_rule_params[:additional_information][:period_unit] = 'weekly'
        invoice_rule_params[:additional_information][:init_date]   = Date.parse("05/06/2017")
        invoice_rule_params[:additional_information][:end_date]    = Date.parse("06/06/2019")

        VCR.use_cassette('invoice_rules/create/failure/rule_weekly_greater_than_one_year') do
          expect {
            subject.create(invoice_rule_params, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end

      it "is valid if periodicity is lower than or equal to one year" do
        invoice_rule_params[:additional_information][:period_unit] = 'weekly'
        invoice_rule_params[:additional_information][:init_date]   = Date.parse("05/06/2017")
        invoice_rule_params[:additional_information][:end_date]    = Date.parse("04/06/2017")

        VCR.use_cassette('invoice_rules/create/success/rule_weekly_lower_than_one_year') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.scheduled_updates).to be_empty
          expect(invoice_rule.additional_information['period_unit']).to eql('weekly')
          expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
          expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
          expect(invoice_rule.receivables_additional_information['month_quantity']).to be_nil
        end
      end

      it "is valid if periodicity is lower or equal than 5 year" do
        invoice_rule_params[:additional_information][:period_unit]    = 'monthly'
        invoice_rule_params[:additional_information][:month_quantity] = 1
        invoice_rule_params[:additional_information][:init_date]      = Date.parse("05/06/2017")
        invoice_rule_params[:additional_information][:end_date]       = Date.parse("04/06/2022")

        VCR.use_cassette('invoice_rules/create/success/rule_monthly_lower_than_five_year') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.scheduled_updates).to be_empty
          expect(invoice_rule.additional_information['period_unit']).to eql('monthly')
          expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
          expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
          expect(invoice_rule.receivables_additional_information['month_quantity']).to be_nil
        end
      end

      it 'creates a weekly rule without scheduled update, without parcels and with month quantity not being null' do
        invoice_rule_params[:additional_information][:period_unit]    = 'weekly'
        invoice_rule_params[:additional_information][:month_quantity] = 6
        invoice_rule_params[:additional_information][:init_date]      = Date.parse("05/06/2017")
        invoice_rule_params[:additional_information][:end_date]       = Date.parse("18/09/2017")

        VCR.use_cassette('invoice_rules/create/success/rule_weekly_with_wrong_month_quantity') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.scheduled_updates).to be_empty
          expect(invoice_rule.additional_information['period_unit']).to eql('weekly')
          expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
          expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
          expect(invoice_rule.receivables_additional_information['month_quantity']).to be_nil
        end
      end

      it 'creates a weekly rule only with period_unit' do
        invoice_rule_params[:additional_information][:period_unit]    = 'weekly'
        invoice_rule_params[:additional_information][:month_quantity] = nil

        VCR.use_cassette('invoice_rules/create/success/rule_weekly_only_with_period_unit') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.scheduled_updates).to be_empty
          expect(invoice_rule.additional_information['period_unit']).to eql('weekly')
          expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
          expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
          expect(invoice_rule.receivables_additional_information['month_quantity']).to be_nil
        end
      end

      it 'creates a monthly rule' do
        invoice_rule_params[:additional_information][:period_unit]    = 'monthly'
        invoice_rule_params[:additional_information][:month_quantity] = 6

        VCR.use_cassette('invoice_rules/create/success/rule_monthly') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.scheduled_updates).to be_empty
          expect(invoice_rule.additional_information['period_unit']).to eql('monthly')
          expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
          expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
          expect(invoice_rule.receivables_additional_information['month_quantity']).to be_nil
        end
      end

      it 'creates a monthly rule without end_date defined' do
        invoice_rule_params[:additional_information][:period_unit]    = 'monthly'
        invoice_rule_params[:additional_information][:month_quantity] = 1

        VCR.use_cassette('invoice_rules/create/success/rule_monthly_without_end_date') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.scheduled_updates).to be_empty
          expect(invoice_rule.additional_information['period_unit']).to eql('monthly')
          expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
          expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
          expect(invoice_rule.receivables_additional_information['month_quantity']).to be_nil
        end
      end

      it 'creates a weekly rule without scheduled update, without parcels, for day quantity without end_date' do
        invoice_rule_params[:additional_information][:period_unit]    = 'weekly'
        invoice_rule_params[:additional_information][:month_quantity] = nil
        invoice_rule_params[:additional_information][:init_date]      = Date.parse("05/06/2017")

        VCR.use_cassette('invoice_rules/create/success/rule_weekly_without_scheduled_update_and_without_end_date') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.scheduled_updates).to be_empty
          expect(invoice_rule.additional_information['period_unit']).to eql('weekly')
          expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
          expect(invoice_rule.receivables_additional_information['parcel_number']).to be_nil
          expect(invoice_rule.receivables_additional_information['month_quantity']).to be_nil
        end
      end

      it "is not valid if periodicity is greater than 5 year" do
        invoice_rule_params[:additional_information][:period_unit]    = 'monthly'
        invoice_rule_params[:additional_information][:month_quantity] = 1
        invoice_rule_params[:additional_information][:init_date]      = Date.parse("05/06/2017")
        invoice_rule_params[:additional_information][:end_date]       = Date.parse("06/06/2023")

        VCR.use_cassette('invoice_rules/create/failure/rule_monthly_greater_than_five_year') do
          expect {
            subject.create(invoice_rule_params, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end

      it 'returns unprocessable entity when period_unit is monthly but month_quantity is not present' do
        invoice_rule_params[:additional_information][:period_unit]    = 'monthly'
        invoice_rule_params[:additional_information][:month_quantity] = nil

        VCR.use_cassette('invoice_rules/create/failure/rule_monthly_only_with_period_unit') do
          expect {
            subject.create(invoice_rule_params, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end

      it 'returns unprocessable entity when month_quantity is not present' do
        invoice_rule_params[:additional_information] = {
          title: "My rule",
          init_date: Date.parse("15/02/2016"),
          end_date: Date.parse("15/02/2017")
        }

        VCR.use_cassette('invoice_rules/create/failure/without_period_unit_and_month_quantity') do
          expect {
            subject.create(invoice_rule_params, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end

      it 'returns unprocessable entity when month_quantity is nil' do
        invoice_rule_params[:additional_information] = {
          month_quantity: nil,
          init_date: Date.parse("05/06/2017"),
          end_date: Date.parse("18/09/2017")
        }

        VCR.use_cassette('invoice_rules/create/failure/rule_with_null_month_quantity') do
          expect {
            subject.create(invoice_rule_params, contract_id: 6666)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end
    end

    it 'creates an invoice_rule without scheduled update, with 3 parcels and for fixed day' do
      invoice_rule_params[:receivables_additional_information][:parcel_number] = 3

      VCR.use_cassette('invoice_rules/create/success/without_supdate_with_parcels_for_fixed_day') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_updates).to be_empty
        expect(invoice_rule.receivables_additional_information['parcel_number']).to eql 3
        expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
      end
    end

    it 'creates an invoice_rule with scheduled update, without parcels and for fixed day' do
      invoice_rule_params[:scheduled_updates] = [
        {
          price_index: 'ipca',
          init_date: '02/10/2016',
          month_quantity: 12,
          days_until_update: 5
        }
      ]

      VCR.use_cassette('invoice_rules/create/success/with_supdate_without_parcels_for_fixed_day') do
        invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_updates).not_to be_empty
        first_scheduled_update = invoice_rule.scheduled_updates.first

        expect(first_scheduled_update['init_date']).to eql '2016-10-02'
        expect(first_scheduled_update['remind_at']).to eql '2016-09-27'
        expect(first_scheduled_update['month_quantity']).to eql 12
        expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
      end
    end

    it 'returns unprocessable entity when scheduled_update has unknown service_item' do
      invoice_rule_params[:scheduled_updates] = [
        {
          service_item_id: 3,
          price_index: 'ipca',
          init_date: '02/10/2016',
          month_quantity: 12,
          days_until_update: 5
        }
      ]

      VCR.use_cassette('invoice_rules/create/failure/supdate_with_invalid_service_item') do
        expect {
          subject.create(invoice_rule_params, contract_id: 9545)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql(422)
        end
      end
    end

    it 'returns unprocessable entity when scheduled_update has more than one scheduled_update' do
      invoice_rule_params[:scheduled_updates] = [
        {
          price_index: 'ipca',
          init_date: '02/10/2016',
          month_quantity: 12,
          days_until_update: 5
        },
        {
          price_index: 'ipca',
          init_date: '02/10/2016',
          month_quantity: 12,
          days_until_update: 5
        }
      ]

      VCR.use_cassette('invoice_rules/create/failure/more_than_one_supdate_without_services') do
        expect {
          subject.create(invoice_rule_params, contract_id: 9545)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql(422)
        end
      end
    end

    context 'when invoice_rule set management_type' do
      it 'creates an invoice_rule with automatic management' do
        VCR.use_cassette('/invoice_rules/create/success/management_automatic') do
          invoice_rules = subject.create(
            invoice_rule_params.merge(
              management_type: 'automatic',
              days_until_automatic_nfe_emission: 3,
              automatic_email_template_id: 1
            ),
            contract_id: 6666
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
            contract_id: 6666
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
            service_item_id: 5,
            description: 'Descrição teste',
            units: 2,
            unit_value: 150.0,
            value: 300.0
          }
        ]

        invoice_rule_params[:scheduled_updates] = [
          {
            service_item_id: 5,
            price_index: 'ipca',
            init_date: '02/10/2016',
            month_quantity: 12,
            days_until_update: 5
          }
        ]

        VCR.use_cassette('invoice_rules/create/success/with_services') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)
          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.gross_value).to eql 300.0
          expect(invoice_rule.services).not_to be_empty
          expect(invoice_rule.scheduled_updates).not_to be_empty

          rule_service = invoice_rule.services.first
          expect(rule_service).to be_a Billimatic::Entities::Service
          expect(rule_service.value).to eql 300.0
          expect(rule_service.description).to eql 'Descrição teste'

          rule_schedule = invoice_rule.scheduled_updates.first
          expect(rule_schedule['service_item_id']).to eql 5
        end
      end

      it 'creates with two services and one scheduled update for one service' do
        invoice_rule_params[:services] = [
          {
            service_item_id: 5,
            description: 'Descrição teste',
            units: 2,
            unit_value: 150.0,
            value: 300.0
          },
          {
            service_item_id: 4,
            description: 'Descrição teste',
            units: 2,
            unit_value: 150.0,
            value: 300.0
          }
        ]

        invoice_rule_params[:scheduled_updates] = [
          {
            service_item_id: 5,
            price_index: 'ipca',
            init_date: '02/10/2016',
            month_quantity: 12,
            days_until_update: 5
          }
        ]

        VCR.use_cassette('invoice_rules/create/success/with_two_services_one_supdate') do
          invoice_rule = subject.create(invoice_rule_params, contract_id: 9545)
          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.id).not_to be_nil
          expect(invoice_rule.gross_value).to eql 600.0
          expect(invoice_rule.services.size).to eql 2
          expect(invoice_rule.scheduled_updates).not_to be_empty
          rule_schedule = invoice_rule.scheduled_updates.first
          expect(rule_schedule['service_item_id']).to eql 5
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
            178729,
            {
              scheduled_updates: [{ month_quantity: '' }]
            },
            contract_id: 9545
          )
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 422
        end
      end
    end

    it 'raises Billimatic::RequestError if existing scheduled update has destroyed service_item' do
      VCR.use_cassette('invoice_rules/update/invalid_service_item_on_scheduled_update') do
        expect {
          subject.update(
            178795,
            {
              services: [{id: 232811, _destroy: true}],
              scheduled_updates: [{ id: 206, service_item_id: 57 }]
            },
            contract_id: 9545
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
            178795,
            {
              scheduled_updates: [{ id: 206, month_quantity: '' }]
            },
            contract_id: 9545
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

    context 'when period_unit is weekly' do
      it 'updates rule to be monthly passing only month_quantity' do
        VCR.use_cassette('invoice_rules/update/success/rule_monthly_passing_month_quantity') do
          invoice_rule = subject.update(
            170828, {
              additional_information: {
                id: 7116, month_quantity: 6, title: 'Updated rule'
              }
            },
            contract_id: 6666
          )

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.additional_information['period_unit']).to eql('monthly')
          expect(invoice_rule.additional_information['title']).to eql('Updated rule')
          expect(invoice_rule.additional_information['month_quantity']).to eql(6)
          expect(invoice_rule.additional_information['accrual_month_quantity']).to eql('same_month')
          expect(invoice_rule.receivables_additional_information['day_number']).to eql 23
        end
      end

      it 'returns unprocessable when updating rule to weekly with rule already set 5-year end_date' do
        VCR.use_cassette('invoice_rules/update/failure/rule_monthly_to_weekly_with_five_years_end_date') do

          expect {
            subject.update(
              170829, {
                additional_information: { id: 7117, title: 'Updated rule', period_unit: 'weekly' }
              }, contract_id: 6666
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end

      it 'returns unprocessable when updating rule weekly for greater than a year end_date' do
        VCR.use_cassette('invoice_rules/update/failure/rule_weekly_passing_invalid_end_date') do

          expect {
            subject.update(
              170829, {
                additional_information: {
                  id: 7117, title: 'Updated rule', period_unit: 'weekly',
                  init_date: '05/06/2017', end_date: '07/07/2019'
                }
              },
              contract_id: 6666
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql(422)
          end
        end
      end

      it 'updates monthly rule init_date' do
        VCR.use_cassette('invoice_rules/update/success/rule_monthly_init_date') do
          invoice_rule = subject.update(
            170829, {
              additional_information: {
                id: 7117, month_quantity: 1, init_date: Date.parse("05/06/2017")
              }
            },
            contract_id: 6666
          )

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.additional_information['period_unit']).to eql('monthly')
          expect(invoice_rule.additional_information['init_date']).to eql('2017-06-05')
        end
      end

      it 'updates rule to be weekly' do
        VCR.use_cassette('invoice_rules/update/success/rule_weekly') do
          invoice_rule = subject.update(
            170829, {
              additional_information: {
                id: 7117, month_quantity: nil, period_unit: 'weekly',
                title: 'weekly rule'
              }
            },
            contract_id: 6666
          )

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.additional_information['period_unit']).to eql('weekly')
          expect(invoice_rule.additional_information['title']).to eql('weekly rule')
          expect(invoice_rule.additional_information['month_quantity']).to be_nil
        end
      end

      it 'updates weekly rule init_date and end_date' do
        VCR.use_cassette('invoice_rules/update/success/rule_weekly_with_init_and_end_date') do
          invoice_rule = subject.update(
            170829, {
              additional_information: {
                id: 7117, month_quantity: nil, title: 'weekly rule',
                init_date: Date.parse("30/11/2017"),
                end_date: Date.parse("27/12/2017")
              }
            },
            contract_id: 6666
          )

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.additional_information['period_unit']).to eql('weekly')
          expect(invoice_rule.additional_information['title']).to eql('weekly rule')
          expect(invoice_rule.additional_information['month_quantity']).to be_nil
          expect(invoice_rule.additional_information['init_date']).to eql('2017-11-30')
          expect(invoice_rule.additional_information['end_date']).to eql('2017-12-27')
        end
      end

      it 'updates rule setting new weekly additional_information' do
        VCR.use_cassette('invoice_rules/update/success/rule_new_weekly_additional_information') do
          invoice_rule = subject.update(
            169928, {
              additional_information: {
                title: "New Weekly Rule",
                period_unit: 'weekly',
                init_date: Date.parse("30/11/2017"),
                end_date: Date.parse("27/01/2018")
              }
            },
            contract_id: 6666
          )

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.additional_information['period_unit']).to eql('weekly')
          expect(invoice_rule.additional_information['title']).to eql('New Weekly Rule')
          expect(invoice_rule.additional_information['month_quantity']).to be_nil
          expect(invoice_rule.additional_information['init_date']).to eql('2017-11-30')
          expect(invoice_rule.additional_information['end_date']).to eql('2018-01-27')
        end
      end

      it 'updates rule setting new monthly additional_information' do
        VCR.use_cassette('invoice_rules/update/success/rule_new_monthly_additional_information') do
          invoice_rule = subject.update(
            169928, {
              additional_information: {
                title: "New Monthly Rule",
                month_quantity: 6,
                init_date: Date.parse("30/11/2017")
              }
            },
            contract_id: 6666
          )

          expect(invoice_rule).to be_a entity_klass
          expect(invoice_rule.additional_information['period_unit']).to eql('monthly')
          expect(invoice_rule.additional_information['title']).to eql('New Monthly Rule')
          expect(invoice_rule.additional_information['month_quantity']).to eql(6)
          expect(invoice_rule.additional_information['init_date']).to eql('2017-11-30')
        end
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
          178735,
          {
            scheduled_updates: [
              {
                price_index: 'ipca',
                init_date: '02/10/2016',
                month_quantity: 12,
                days_until_update: 5
              }
            ]
          },
          contract_id: 9545
        )

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        expect(invoice_rule.scheduled_updates).not_to be_empty
        first_schedule = invoice_rule.scheduled_updates.first
        expect(first_schedule['execution_date']).to eql '2016-10-02'
        expect(first_schedule['remind_at']).to eql '2016-09-27'
      end
    end

    it 'updates rule existing scheduled update' do
      VCR.use_cassette('invoice_rules/update/success/existing_scheduled_update') do
        invoice_rule = subject.update(
          178735,
          {
            scheduled_updates: [
              {
                id: 209,
                service_item_id: 57,
                price_index: 'igpm',
                month_quantity: 1,
                days_until_update: 2
              }
            ]
          },
          contract_id: 9545
        )

        expect(invoice_rule).to be_a entity_klass
        expect(invoice_rule.id).not_to be_nil
        first_schedule = invoice_rule.scheduled_updates.first
        expect(first_schedule['execution_date']).to eql '2016-10-02'
        expect(first_schedule['remind_at']).to eql '2016-09-30'
        expect(first_schedule['service_item_id']).to eql 57
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
      it 'updates an invoice_rules with manual management' do
        VCR.use_cassette('/invoice_rules/update/success/management_manual') do
          invoice_rules = subject.update(
            168525, {
              management_type: 'manual',
              days_until_automatic_nfe_emission: 0,
              automatic_email_template_id: 0
            },
            contract_id: 6666
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
            168531, {
              management_type: 'automatic',
              days_until_automatic_nfe_emission: 5,
              automatic_email_template_id: 3
            },
            contract_id: 6666
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
            168531, { automatic_email_template_id: 2 }, contract_id: 6666
          )

          expect(invoice).to be_a entity_klass
          expect(invoice.management_type).to eql('automatic')
          expect(invoice.days_until_automatic_nfe_emission).to eql(5)
          expect(invoice.automatic_email_template_id).to eql(2)
        end
      end
    end
  end

  describe '#destroy' do
    it 'raises Billimatic::RequestError when contract is not found' do
      VCR.use_cassette('/invoice_rules/destroy/failure/contract_not_found') do
        expect {
          subject.destroy(179986, contract_id: 50_000)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql(404)
        end
      end
    end

    it 'raises Billimatic::RequestError when invoice_rule is not found' do
      VCR.use_cassette('/invoice_rules/destroy/failure/invoice_rule_not_found') do
        expect {
          subject.destroy(1_000_000, contract_id: 8818)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql(404)
        end
      end
    end

    it 'returns true when successfully deletes invoice_rule' do
      VCR.use_cassette('/invoice_rules/destroy/success/invoice_rule_successfully_deleted') do
        expect(subject.destroy(179986, contract_id: 8818)).to be true
      end
    end
  end
end
