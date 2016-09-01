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
          subject.create(organization_id: 50, attributes: plan_params)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    context 'a plan without features or products' do
      it 'successfully creates a plan' do
        VCR.use_cassette('plans/create/success_without_features_or_products') do
          plan = subject.create(organization_id: 4, attributes: plan_params)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
        end
      end

      it 'raises Billimatic::RequestError if plan attributes are invalid' do
        plan_params[:name] = ''

        VCR.use_cassette('plans/create/invalid_plan_failure') do
          expect {
            subject.create(organization_id: 4, attributes: plan_params)
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
          plan = subject.create(organization_id: 4, attributes: { plan: plan_params })

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features).not_to be_empty
        end
      end

      it 'raises Billimatic::RequestError if feature is invalid' do
        plan_params[:features] = [{ value: '', tag: 'feat.' }]

        VCR.use_cassette('plans/create/invalid_feature_failure') do
          expect {
            subject.create(organization_id: 4, attributes: { plan: plan_params })
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
          plan = subject.create(organization_id: 4, attributes: { plan: plan_params })

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products).not_to be_empty
        end
      end

      it 'raises Billimatic::RequestError if product is invalid' do
        plan_params[:products] = [{ service_item_id: 1, unit_value: 100, value: 100 }]

        VCR.use_cassette('plans/create/invalid_product_failure') do
          expect {
            subject.create(organization_id: 4, attributes: { plan: plan_params })
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
          plan = subject.create(organization_id: 4, attributes: { plan: plan_params })

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features).not_to be_empty
          expect(plan.products).not_to be_empty
        end
      end
    end
  end
end
