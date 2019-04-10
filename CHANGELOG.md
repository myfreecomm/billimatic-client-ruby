# Changelog

## Next version

## v0.22.0
- Adds EmailTemplate entity.
- Adds EmailTemplate#list endpoint.

## v0.21.0
- Adds ServiceItem#list endpoint.

## v0.20.0
- Adds InvoiceTemplate entity.
- Adds InvoiceTemplate#list and InvoiceTemplate#show endpoints.
- Changes links on README for new API documentation.
- Allows `invoice_template_id` attribute and InvoiceTemplate attributes override to be sent on InvoiceRule#create.

## v0.19.1
- Adds `apply_negative_updates` attribute on InvoiceRule entity.

## v0.19.0
- Adds Company#list endpoint.
- Adds Person#list endpoint.
- Adds `notification_ruler_id` attribute on Invoice entity.
- Adds `notification_ruler_id` attribute on InvoiceRule entity.
- Adds `billet_notification_ruler_id` and `payment_gateway_notification_ruler_id` attributes on Plan entity.

## v0.18.2
- Adds `notify_customer` attribute on InvoiceRule entity.

## v0.18.1
- Adds `company_name`, `address`, `number`, `complement`, `zipcode`, `district`, `city` and `state` attributes on Organization entity.

## v0.18.0
- Adds Person#show endpoint.

## v0.17.0
- Adds InvoiceRule#list and InvoiceRule#destroy endpoints.
- Adds `contract_id` field on InvoiceRule entity.

## v0.16.0
- Changes `scheduled_updates` field on InvoiceRule entity, to become a collection of scheduled_update hashes.

## v0.15.0
- Fixes README.md details for update endpoints, with correct HTTP method used.
- Adds `city_inscription`, `myfinance_customer_id` and `myfinance_errors` attributes on Company entity.
- Adds `myfinance_customer_id` and `myfinance_errors` attributes on Person entity.
- Adds `estimated_issue_date`, `myfinance_sale_account_id` and `myfinance_sale_account_name` attributes on Invoice entity.
- Adds `myfinance_sale_account_id` and `myfinance_sale_account_name` attributes on InvoiceRule entity.
- Adds `myfinance_billet_sale_account_id`, `myfinance_billet_sale_account_name`, `myfinance_payment_gateway_sale_account_id` and `myfinance_payment_gateway_sale_account_name` attributes on Plan entity.
- Adds `myfinance_sale_id` attribute and changes `finance_errors` attribute to `myfinance_errors` on Receivable entity.
- Adds Contract#show endpoint.

## v0.14.1

- Adds `cobrato_payment_gateway_charge_config_id` and `cobrato_payment_gateway_charge_config_name` attributes on Contract and Subscription entities.
- Adds `payment_information` attribute on Invoice and InvoiceRule entities, which represents an association to a PaymentInformation entity.
