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
      has_trial: true,
      trial_period: 30,
      redirect_url: "http://www.empresa.com/foo",
      emites_service_values_id: 47,
      cobrato_billet_charge_config_id: 110,
      finance_category: 'Outros',
      finance_revenue_center: 'CR1',
      created_at: "2016-05-02T16:55:10.000-03:00"
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like "entity_attributes", [
                    :id, :name, :description, :price, :billing_period,
                    :translated_billing_period, :has_trial, :trial_period,
                    :redirect_url, :emites_service_values_id,
                    :cobrato_billet_charge_config_id, :finance_category,
                    :finance_revenue_center, :created_at
                  ]
end