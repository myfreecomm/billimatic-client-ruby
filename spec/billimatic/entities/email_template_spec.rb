require 'spec_helper'

describe Billimatic::Entities::EmailTemplate do
  let(:attributes) do
    {
      id: 3,
      company_id: 1,
      name: "Notificação de Teste",
      cc: "",
      from: "",
      body: "Foo Bar Zaz",
      subject: "Notificação de Teste",
      description: "Descrição",
      include_billet: true,
      include_invoice_pdf: false,
      include_nfse_pdf: false,
      include_nfse_xml: false,
      include_attachments: false,
      default_template: false,
      subscription_default_template: false,
      created_at: "2019-02-11T09:30:44.567-02:00",
    }
  end

  subject { described_class.new(attributes) }

  it_behaves_like "entity_attributes", [
                    :id, :company_id, :name, :cc, :from, :body, :subject,
                    :description, :include_billet, :include_invoice_pdf,
                    :include_nfse_pdf, :include_nfse_xml, :include_attachments,
                    :default_template, :subscription_default_template,
                    :created_at
                  ]
end
