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
    let(:plan_params) do
      {
        name: 'Plano de Teste',
        description: 'Description',
        price: 100.0,
        billing_period: 1,
        has_trial: false,
        redirect_url: 'http://nexaas.com',
        charging_method: 'pre_paid',
        cobrato_billet_charge_config_id: 128,
        cobrato_billet_charge_config_name: 'Cobrança não registrada'
      }
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
          plan = subject.create(plan_params, organization_id: 564)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
        end
      end

      it 'raises Billimatic::RequestError if plan attributes are invalid' do
        plan_params[:name] = ''

        VCR.use_cassette('plans/create/invalid_plan_failure') do
          expect {
            subject.create(plan_params, organization_id: 564)
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
          plan = subject.create(plan_params, organization_id: 564)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features).not_to be_empty
        end
      end

      it 'raises Billimatic::RequestError if feature is invalid' do
        plan_params[:features] = [{ value: '', tag: 'feat.' }]

        VCR.use_cassette('plans/create/invalid_feature_failure') do
          expect {
            subject.create(plan_params, organization_id: 564)
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end
    end

    context 'a plan with products' do
      it 'successfully creates a plan' do
        plan_params[:products] = [{ service_item_id: 1, description: 'Nova descrição', units: 1, unit_value: 100, value: 100 }]

        VCR.use_cassette('plans/create/success_with_products') do
          plan = subject.create(plan_params, organization_id: 564)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products).not_to be_empty
          expect(plan.products.first.description).to eql('Nova descrição')
        end
      end

      it 'raises Billimatic::RequestError if product is invalid' do
        plan_params[:products] = [{ service_item_id: 1, unit_value: 100, value: 100 }]

        VCR.use_cassette('plans/create/invalid_product_failure') do
          expect {
            subject.create(plan_params, organization_id: 564)
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
          plan = subject.create(plan_params, organization_id: 564)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features).not_to be_empty
          expect(plan.products).not_to be_empty
        end
      end
    end

    context 'when plan has installments' do
      let(:http) { Billimatic::Http.new('6995d1ad4f1ed7465bb122ee759a7aa6') }

      subject { described_class.new(http) }

      before { Billimatic.configuration.host = "http://localhost:3000" }

      it 'success creates a plan with installments' do
        plan_params[:features] = [{ description: 'feature', value: '100', tag: 'feat.' }]
        plan_params[:products] = [{ service_item_id: 1, units: 1, unit_value: 100, value: 100 }]
        plan_params[:allow_installments] = true
        plan_params[:installments_limit] = 36

        VCR.use_cassette('plans/create/success_with_installments') do
          plan = subject.create(plan_params, organization_id: 1)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features).not_to be_empty
          expect(plan.products).not_to be_empty
          expect(plan.allow_installments).to be_truthy
          expect(plan.installments_limit).to eql(36)
        end
      end

      it 'success creates a plan without installments' do
        plan_params[:features] = [{ description: 'feature', value: '100', tag: 'feat.' }]
        plan_params[:products] = [{ service_item_id: 1, units: 1, unit_value: 100, value: 100 }]
        plan_params[:allow_installments] = false

        VCR.use_cassette('plans/create/success_without_installments') do
          plan = subject.create(plan_params, organization_id: 1)

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features).not_to be_empty
          expect(plan.products).not_to be_empty
          expect(plan.allow_installments).to be_falsey
        end
      end
    end
  end

  describe '#update' do
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
          subject.update(102, plan_params, organization_id: 564)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'updates successfully plan attributes' do
      VCR.use_cassette('plans/update/success') do
        plan = subject.update(
          140, { name: 'Updated Plan', price: 200.0 }, organization_id: 564
        )

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
              360,
              { features: [{ value: '' }] },
              organization_id: 564
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
              360,
              { features: [{ id: 12947, value: '' }] },
              organization_id: 564
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'successfully updates plan with a new feature' do
        VCR.use_cassette('plans/update/success_with_new_feature') do
          plan = subject.update(
            140,
            { features: [{ value: '200', description: 'new feature', tag: 'new feat.' }] },
            organization_id: 564
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features.count).to eql 1
        end
      end

      it 'successfully updates plan and its existing feature' do
        VCR.use_cassette('plans/update/success_with_existing_feature') do
          plan = subject.update(
            141,
            { features: [{ id: 61, value: '300' }] },
            organization_id: 564
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features.first.value).to eql '300'
        end
      end

      it 'successfully updates plan and delete its feature' do
        VCR.use_cassette('plans/update/success_deleting_feature') do
          plan = subject.update(
            141,
            { features: [{ id: 61, _destroy: true }] },
            organization_id: 564
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.features.first).to be_nil
        end
      end
    end

    context 'plan with products' do
      it 'raises Billimatic::RequestError if an invalid new product is sent' do
        VCR.use_cassette('plans/update/invalid_new_product_failure') do
          expect {
            subject.update(
              140,
              { products: [{ service_item_id: 1 }] },
              organization_id: 564
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
              142,
              { products: [{ id: 183066, service_item_id: 1, unit_value: '', value: 150 }] },
              organization_id: 564
            )
          }.to raise_error(Billimatic::RequestError) do |error|
            expect(error.code).to eql 422
          end
        end
      end

      it 'successfully updates plan with a new product' do
        VCR.use_cassette('plans/update/success_with_new_product') do
          plan = subject.update(
            142,
            { products: [{ service_item_id: 1, units: 1, unit_value: 300.0, value: 300.0 }] },
            organization_id: 564
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products.count).to eql 2
          expect(plan.products[1].value).to eql 300.0
          expect(plan.price).to eql 400.0
        end
      end

      it 'successfully updates plan and its existing product' do
        VCR.use_cassette('plans/update/success_with_existing_product') do
          plan = subject.update(
            4,
            { products: [{ id: 79385, unit_value: 150.0, value: 150.0, description: 'Descrição teste' }] },
            organization_id: 564
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products.first.value).to eql 150.0
          expect(plan.products.first.description).to eql('Descrição teste')
          expect(plan.price).to eql 150.0
        end
      end

      it 'successfully updates plan and deletes existing product' do
        VCR.use_cassette('plans/update/success_deleting_product') do
          plan = subject.update(
              142,
              { products: [{ id: 183066, _destroy: true }] },
              organization_id: 564
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products.count).to eql 1
          expect(plan.products[1]).to be_nil
        end
      end
    end


    context 'when plan has installments' do
      let(:http) { Billimatic::Http.new('6995d1ad4f1ed7465bb122ee759a7aa6') }

      subject { described_class.new(http) }

      before { Billimatic.configuration.host = "http://localhost:3000" }

      it 'successfully updates plan with installments' do
        VCR.use_cassette('plans/update/success_with_installments') do
          plan = subject.update(
              5,
              { allow_installments: true, installments_limit:48 },
              organization_id: 1
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products.count).to eql 1
          expect(plan.products[1]).to be_nil
          expect(plan.allow_installments).to be_truthy
          expect(plan.installments_limit).to eql(48)
        end
      end

      it 'successfully updates plan without installments' do
        VCR.use_cassette('plans/update/success_without_installments') do
          plan = subject.update(
              6,
              { allow_installments: false },
              organization_id: 1
          )

          expect(plan).to be_a entity_klass
          expect(plan.id).not_to be_nil
          expect(plan.products.count).to eql 1
          expect(plan.products[1]).to be_nil
          expect(plan.allow_installments).to be_falsey
          expect(plan.installments_limit).to be_nil
        end
      end
    end
  end

  describe '#destroy' do
    it "raises Billimatic::RequestError if organization isn't found" do
      VCR.use_cassette('plans/destroy/not_found_organization_failure') do
        expect {
          subject.destroy(141, organization_id: 100)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it "raises Billimatic::RequestError if plan isn't found" do
      VCR.use_cassette('plans/destroy/not_found_plan_failure') do
        expect {
          subject.destroy(1000, organization_id: 564)
        }.to raise_error(Billimatic::RequestError) do |error|
          expect(error.code).to eql 404
        end
      end
    end

    it 'deletes successfully a plan' do
      VCR.use_cassette('plans/destroy/success') do
        expect(subject.destroy(140, organization_id: 564)).to be true
      end
    end
  end
end
