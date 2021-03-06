module Billimatic
  module Entities
    class Contract < Base
      attribute :id, Integer
      attribute :name, String
      attribute :title, String
      attribute :token, String
      attribute :description, String
      attribute :customer_id, Integer
      attribute :customer_type, String
      attribute :supplier_id, Integer
      attribute :supplier_type, String
      attribute :state, String
      attribute :comments, String
      attribute :init_date, Date
      attribute :end_date, Date
      attribute :created_at, DateTime
      attribute :kind, String
      attribute :registration_method, String
      attribute :overdue, Boolean
      attribute :valid_until, Date
      attribute :status, String
      attribute :cancel_date, Date
      attribute :cancel_reason, String
      attribute :cobrato_payment_gateway_charge_config_id, Integer
      attribute :cobrato_payment_gateway_charge_config_name, String
      attribute :overdue_automatic_management, Boolean
      attribute :plan, Plan
    end
  end
end
