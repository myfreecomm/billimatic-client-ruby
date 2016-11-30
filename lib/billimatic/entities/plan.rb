module Billimatic
  module Entities
    class Plan < Base
      attribute :id, Integer
      attribute :name, String
      attribute :description, String
      attribute :price, Decimal
      attribute :billing_period, Integer
      attribute :translated_billing_period, String
      attribute :charging_method, String
      attribute :translated_charging_method, String
      attribute :has_trial, Boolean
      attribute :trial_period, Integer
      attribute :redirect_url, String
      attribute :features, Array[PlanFeature]
      attribute :emites_service_values_id, Integer
      attribute :emites_service_value_name, String
      attribute :cobrato_billet_charge_config_id, Integer
      attribute :cobrato_billet_charge_config_name, String
      attribute :cobrato_billet_charge_template_id, Integer
      attribute :cobrato_billet_charge_template_name, String
      attribute :cobrato_payment_gateway_charge_config_id, Integer
      attribute :cobrato_payment_gateway_charge_config_name, String
      attribute :finance_category, String
      attribute :finance_revenue_center, String
      attribute :created_at, DateTime
      attribute :products, Array[Product]
    end
  end
end
