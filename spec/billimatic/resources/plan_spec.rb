require 'spec_helper'

describe Billimatic::Resources::Plan do
  let(:entity_klass) { Billimatic::Entities::Plan }
  let(:http) { Billimatic::Http.new('bfe97f701f615edf41587cbd59d6a0e8') }

  subject { described_class.new(http) }

  it 'has a instance of Billimatic::Http' do
    expect(subject.http).to eq(http)
  end

  describe '#list' do
    it 'returns a collection of plans for an organization' do
      VCR.use_cassette('plans/list/success') do
        plans = subject.list(organization_id: 564)

        expect(plans.size).to eql 1
        expect(plans.first).to be_an entity_klass
        expect(plans.first.products).not_to be_empty
        expect(plans.first.features).not_to be_empty
      end
    end

    it 'returns not found it the organization is not found' do
      VCR.use_cassette('plans/list/organization_not_found') do
        expect { subject.list(organization_id: 51) }.to raise_error(
                                         Billimatic::RequestError
                                       ) { |error| expect(error.code).to eql(404) }
      end
    end
  end

  describe '#create' do
    let(:http) { Billimatic::Http.new('d0cb3c0eae88857de3266c7b6dd7298d') }

    let(:plan_params) do
      {
        name: 'Plan',
        description: 'Description for Plan',
        price: 100.0,
        billing_period: 1,
        has_trial: false,
        redirect_url: 'http://nexaas.com',
        charging_method: 'pre_paid',
        cobrato_billet_charge_config_id: 128,
        cobrato_billet_charge_config_name: 'Cobrança não registrada'
      }
    end

    before do
      Billimatic.configuration.host = 'http://localhost:3000'
    end

    it 'raises Billimatic::RequestError if organization is not found' do
      VCR.use_cassette('plans/create/not_found_organization_failure') do
        expect {
          subject.create(plan_params, organization_id: 50)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    context 'a plan without features or products' do
      it 'successfully creates a plan' do
        VCR.use_cassette('plans/create/success_without_features_or_products') do
          plan = subject.create(plan_params, organization_id: 4)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
        end
      end

      it 'raises Billimatic::RequestError if plan attributes are invalid' do
        plan_params[:name] = ''

        VCR.use_cassette('plans/create/invalid_plan_failure') do
          expect {
            subject.create(plan_params, organization_id: 4)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end

    context 'a plan with features' do
      it 'successfully creates a plan' do
        plan_params[:features] = [{ description: 'feature', value: '100', tag: 'feat.' }]

        VCR.use_cassette('plans/create/success_with_features') do
          plan = subject.create(plan_params, organization_id: 4)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features).not_to be_empty
        end
      end

      it 'raises Billimatic::RequestError if feature is invalid' do
        plan_params[:features] = [{ value: '', tag: 'feat.' }]

        VCR.use_cassette('plans/create/invalid_feature_failure') do
          expect {
            subject.create(plan_params, organization_id: 4)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end

    context 'a plan with products' do
      it 'successfully creates a plan' do
        plan_params[:products] = [{ service_item_id: 1, units: 1, unit_value: 100, value: 100 }]

        VCR.use_cassette('plans/create/success_with_products') do
          plan = subject.create(plan_params, organization_id: 4)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products).not_to be_empty
        end
      end

      it 'raises Billimatic::RequestError if product is invalid' do
        plan_params[:products] = [{ service_item_id: 1, unit_value: 100, value: 100 }]

        VCR.use_cassette('plans/create/invalid_product_failure') do
          expect {
            subject.create(plan_params, organization_id: 4)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end

    context 'a plan with both features and products' do
      it 'successfully creates a plan' do
        plan_params[:features] = [{ description: 'feature', value: '100', tag: 'feat.' }]
        plan_params[:products] = [{ service_item_id: 1, units: 1, unit_value: 100, value: 100 }]

        VCR.use_cassette('plans/create/success_with_features_and_products') do
          plan = subject.create(plan_params, organization_id: 4)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features).not_to be_empty
          expect(plan.products).not_to be_empty
        end
      end
    end
  end

  describe '#update' do
    let(:http) { Billimatic::Http.new('d0cb3c0eae88857de3266c7b6dd7298d') }

    let(:plan_params) do
      {
        name: 'Plan',
        description: 'Description for Plan',
        price: 100.0,
        billing_period: 1,
        has_trial: false,
        redirect_url: 'http://nexaas.com',
        charging_method: 'pre_paid',
        cobrato_billet_charge_config_id: 128,
        cobrato_billet_charge_config_name: 'Cobrança não registrada'
      }
    end

    before do
      Billimatic.configuration.host = 'http://localhost:3000'
    end

    it 'raises Billimatic::RequestError if organization is not found' do
      VCR.use_cassette('plans/update/not_found_organization_failure') do
        expect {
          subject.update(12, plan_params, organization_id: 50)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'raises Billimatic::RequestError if plan is not found' do
      VCR.use_cassette('plans/update/not_found_plan_failure') do
        expect {
          subject.update(102, plan_params, organization_id: 4)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'updates successfully plan attributes' do
      VCR.use_cassette('plans/update/success') do
        plan = subject.update(50, { name: 'Updated Plan', price: 200.0 }, organization_id: 4)

        expect(plan).to be_a entity_klass
        expect(plan.name).to eql 'Updated Plan'
        expect(plan.price).to eql 200.0
      end
    end

    context 'plan with features' do
      it 'raises Billimatic::RequestError if an invalid new feature is sent' do
        VCR.use_cassette('plans/update/invalid_new_feature_failure') do
          expect {
            subject.update(
              50,
              { features: [{ description: '', tag: 'feat.' }] },
              organization_id: 4
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'raises Billimatic::RequestError with an invalid attempt to update a feature' do
        VCR.use_cassette('plans/update/invalid_existing_feature_failure') do
          expect {
            subject.update(
              50,
              { features: [{ value: '', description: '' }] },
              organization_id: 4
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'successfully updates plan with a new feature' do
        VCR.use_cassette('plans/update/success_with_new_feature') do
          plan = subject.update(
            50,
            { features: [{ value: '200', description: 'new feature', tag: 'new feat.' }] },
            organization_id: 4
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features.count).to eql 2
        end
      end

      it 'successfully updates plan and its existing feature' do
        VCR.use_cassette('plans/update/success_with_existing_feature') do
          plan = subject.update(
            50,
            { features: [{ id: 33, value: '300' }] },
            organization_id: 4
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features.first.value).to eql '300'
        end
      end
    end

    context 'plan with products' do
      it 'raises Billimatic::RequestError if an invalid new product is sent' do
        VCR.use_cassette('plans/update/invalid_new_product_failure') do
          expect {
            subject.update(
              50,
              { products: [{ service_item_id: 1 }] },
              organization_id: 4
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'raises Billimatic::RequestError with an invalid attempt to update a product' do
        VCR.use_cassette('plans/update/invalid_existing_product_failure') do
          expect {
            subject.update(
              52,
              { products: [{ id: 23916, service_item_id: 1, unit_value: '', value: 150 }] },
              organization_id: 4
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'successfully updates plan with a new product' do
        VCR.use_cassette('plans/update/success_with_new_product') do
          plan = subject.update(
            50,
            { products: [{ service_item_id: 1, units: 1, unit_value: 300.0, value: 300.0 }] },
            organization_id: 4
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products.count).to eql 1
          expect(plan.products.first.value).to eql 300.0
          expect(plan.price).to eql 300.0
        end
      end

      it 'successfully updates plan and its existing product' do
        VCR.use_cassette('plans/update/success_with_existing_product') do
          plan = subject.update(
            50,
            { products: [{ id: 23920, unit_value: 150.0, value: 150.0 }] },
            organization_id: 4
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products.first.value).to eql 150.0
          expect(plan.price).to eql 150.0
        end
      end
    end
  end
end
