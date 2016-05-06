module Billimatic
  module Entities
    class Plan < Base
      attribute :id, Integer
      attribute :name, String
      attribute :description, String
      attribute :price, Decimal
      attribute :billing_period, Integer
      attribute :translated_billing_period, String
      attribute :has_trial, Boolean
      attribute :trial_period, Integer
      attribute :redirect_url, String
      attribute :features, Array
      attribute :emites_service_values_id, Integer
      attribute :cobrato_billet_charge_config_id, Integer
      attribute :finance_category, String
      attribute :finance_revenue_center, String
      attribute :created_at, DateTime
      attribute :products, Array[Product]
    end
  end
end
