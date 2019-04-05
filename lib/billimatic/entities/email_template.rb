module Billimatic
  module Entities
    class EmailTemplate < Base
      attribute :id, Integer
      attribute :company_id, Integer
      attribute :name, String
      attribute :cc, String
      attribute :from, String
      attribute :body, String
      attribute :subject, String
      attribute :description, String
      attribute :include_billet, Integer
      attribute :include_nfse_pdf, Integer
      attribute :include_nfse_xml, Integer
      attribute :include_attachments, Integer
      attribute :include_invoice_pdf, Integer
      attribute :default_template, Integer
      attribute :subscription_default_template, Integer
      attribute :created_at, DateTime
      attribute :updated_at, DateTime
    end
  end
end
