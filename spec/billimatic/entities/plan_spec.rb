require 'spec_helper'

describe Billimatic::Entities::Plan do
  let(:attributes) do
    {
      id: 1,
      name: "Plano 1",
      description: 'Descrição do plano',
      price: 50.00,
      billing_period: 1,
      translated_billing_period: 'mensalmente',
      charging_method: "pre_paid",
      translated_charging_method: "Pré-pago",
      has_trial: true,
      trial_period: 30,
      redirect_url: "http://www.empresa.com/foo",
      features: [
        Billimatic::Entities::PlanFeature.new(
          id: 1, description: 'Até 5 usuários', value: 'Foo', tag: 'Tag'
        ),
        Billimatic::Entities::PlanFeature.new(
          id: 2, description: '50 GB de armazenamento', value: 'Bar', tag: 'Tag'
        )
      ],
      emites_service_values_id: 47,
      cobrato_billet_charge_config_id: 110,
      cobrato_payment_gateway_charge_config_id: 137,
      finance_category: 'Outros',
      finance_revenue_center: 'CR1',
      created_at: "2016-05-02T16:55:10.000-03:00",
      products: [
        Billimatic::Entities::Product.new(
          id: 1,
          name: 'Serviço',
          unit_value: 150.0,
          units: 2.0,
          value: 300.0
        )
      ]
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like "entity_attributes", [
                    :id, :name, :description, :price, :billing_period,
                    :translated_billing_period, :charging_method,
                    :translated_charging_method, :has_trial, :trial_period,
                    :redirect_url, :features, :emites_service_values_id,
                    :cobrato_billet_charge_config_id, :cobrato_payment_gateway_charge_config_id,
                    :finance_category, :finance_revenue_center, :created_at, :products
                  ]
end
