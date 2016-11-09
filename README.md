# Billimatic API Ruby Client

This is the official Ruby client for the [Billimatic](http://www.billimatic.com.br) API.

[![Gem Version](https://badge.fury.io/rb/billimatic-client.png)](https://rubygems.org/gems/billimatic-client)
[![Build Status](https://api.travis-ci.org/myfreecomm/billimatic-client-ruby.svg?branch=master)](https://travis-ci.org/myfreecomm/billimatic-client-ruby)
[![Test Coverage](https://codeclimate.com/github/myfreecomm/billimatic-client-ruby/badges/coverage.svg)](https://codeclimate.com/github/myfreecomm/billimatic-client-ruby/coverage)
[![Code Climate Grade](https://codeclimate.com/github/myfreecomm/billimatic-client-ruby/badges/gpa.svg)](https://codeclimate.com/github/myfreecomm/billimatic-client-ruby)
[![Inline docs](http://inch-ci.org/github/myfreecomm/billimatic-client-ruby.svg?branch=master)](http://inch-ci.org/github/myfreecomm/billimatic-client-ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'billimatic-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install billimatic-client

## Configuration

##### Use Billimatic.configure to setup your environment:

```ruby
require 'billimatic'

Billimatic.configure do |config|
  config.host = 'https://sandbox.billimatic.com.br' # defaults to 'https://app.billimatic.com.br'
  config.user_agent = 'My App v1.0' # optional, but you should pass a custom user-agent identifying your app
end
```

## Usage

##### Given your token, create an instance of Billimatic::Client, as below:

```ruby
client = Billimatic.client("YOUR_TOKEN_HERE")
```

##### Now you have acess to every API endpoint:

* [Organizations API](https://app.billimatic.com.br/docs/api#!/organizations) as `client.organizations`
* [Plans API](https://app.billimatic.com.br/docs/api#!/plans) as `client.plans`
* [Subscriptions API](https://app.billimatic.com.br/docs/api#!/subscriptions) as `client.subscriptions`
* [Contracts API](https://app.billimatic.com.br/docs/api#!/contracts) as `client.contracts`
* [Invoices API](https://app.billimatic.com.br/docs/api#!/invoices) as `client.invoices`
* [Invoice Rules API](https://app.billimatic.com.br/docs/api#!/invoice_rules) as `client.invoice_rules`
* [Companies API](https://app.billimatic.com.br/docs/api#!/companies) as `client.companies`
* [Service Items API](https://app.billimatic.com.br/docs/api#!/service_items) as `client.service_items`

## Endpoints

#### [Organizations](https://app.billimatic.com.br/docs/api#!/organizations)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/organizations/API_V1_Organizations_search_get_0" target="_blank">
                /api/v1/organizations/search?cnpj=:cnpj
            </a>
        </td>
        <td>
            <code>client.organizations.search(cnpj: cnpj)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/organizations/API_V1_Organizations_create_post_1" target="_blank">
                /api/v1/organizations
            </a>
        </td>
        <td>
            <code>client.organizations.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/organizations/API_V1_Organizations_update_patch_2" target="_blank">
                /api/v1/organizations/:id
            </a>
        </td>
        <td>
            <code>client.organizations.update(id, attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>DELETE</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/organizations/API_V1_Organizations_destroy_delete_3" target="_blank">
                /api/v1/organizations/:id
            </a>
        </td>
        <td>
            <code>client.organizations.destroy(id)</code>
        </td>
    </tr>
</table>

#### [Plans](https://app.billimatic.com.br/docs/api#!/plans)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/plans/API_V1_Plans_index_get_0" target="_blank">
                /api/v1/organizations/:organization_id/plans
            </a>
        </td>
        <td>
            <code>client.plans.list(organization_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/plans/API_V1_Plans_create_post_1" target="_blank">
                /api/v1/organizations/:organization_id/plans
            </a>
        </td>
        <td>
            <code>client.plans.create(attributes_hash, organization_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/plans/API_V1_Plans_update_patch_2" target="_blank">
                /api/v1/organizations/:organization_id/plans/:id
            </a>
        </td>
        <td>
            <code>client.plans.update(id, attributes_hash, organization_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>DELETE</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/plans/API_V1_Plans_destroy_delete_3" target="_blank">
                /api/v1/organizations/:organization_id/plans/:id
            </a>
        </td>
        <td>
            <code>client.plans.destroy(id, organization_id: id)</code>
        </td>
    </tr>
</table>

#### [Subscriptions](https://app.billimatic.com.br/docs/api#!/subscriptions)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/subscriptions/API_V1_Subscriptions_show_by_token_get_1" target="_blank">
                /api/v1/subscriptions/token/:token
            </a>
        </td>
        <td>
            <code>client.subscriptions.show(token: token)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/subscriptions/API_V1_Subscriptions_create_post_2" target="_blank">
                /api/v1/subscriptions
            </a>
        </td>
        <td>
            <code>client.subscriptions.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/checkouts/API_V1_Subscription_Checkouts_create_post_0" target="_blank">
                /api/v1/subscriptions/checkout/:token
            </a>
        </td>
        <td>
            <code>client.subscriptions.checkout(attributes_hash, token: token)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/plan_modifications/API_V1_Subscription_PlanModifications_change_plan_patch_0" target="_blank">
                /api/v1/subscriptions/:token/change_plan
            </a>
        </td>
        <td>
            <code>client.subscriptions.change_plan(token: token, new_plan_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/payment_informations/API_V1_Subscription_PaymentInformations_update_patch_0" target="_blank">
                /api/v1/subscriptions/:token/update_payment_information
            </a>
        </td>
        <td>
            <code>client.subscriptions.update_payment_information(attributes_hash, token: token)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/subscriptions/API_V1_Subscriptions_cancel_patch_0" target="_blank">
                /api/v1/subscriptions/:token/cancel
            </a>
        </td>
        <td>
            <code>client.subscriptions.cancel(token: token)</code>
        </td>
    </tr>
</table>

#### [Contracts](https://app.billimatic.com.br/docs/api#!/contracts)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/contracts/API_V1_Contracts_search_get_0" target="_blank">
                /api/v1/contracts/search?name=:name
            </a>
        </td>
        <td>
            <code>client.contracts.search(name: name)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/contracts/API_V1_Contracts_create_post_1" target="_blank">
                /api/v1/contracts
            </a>
        </td>
        <td>
            <code>client.contracts.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/contracts/API_V1_Contracts_update_patch_2" target="_blank">
                /api/v1/contracts/:id
            </a>
        </td>
        <td>
            <code>client.contracts.update(id, attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>DELETE</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/contracts/API_V1_Contracts_destroy_delete_3" target="_blank">
                /api/v1/contracts/:id
            </a>
        </td>
        <td>
            <code>client.contracts.destroy(id)</code>
        </td>
    </tr>
</table>

#### [Invoices](https://app.billimatic.com.br/docs/api#!/invoices)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/invoices/API_V1_Invoices_search_get_0" target="_blank">
                /api/v1/contracts/:contract_id/invoices/search?issue_date_from=:issue_date_from&issue_date_to=:issue_date_to
            </a>
        </td>
        <td>
            <code>client.invoices.search(contract_id: id, issue_date_from: 'dd-mm-yyyy', issue_date_to: 'dd-mm-yyyy')</code>
        </td>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/invoices/API_V1_Invoices_show_get_2" target="_blank">
                /api/v1/contracts/:contract_id/invoices/:id
            </a>
        </td>
        <td>
            <code>client.invoices.show(id, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/invoices/API_V1_Invoices_create_post_1" target="_blank">
                /api/v1/contracts/:contract_id/invoices
            </a>
        </td>
        <td>
            <code>client.invoices.create(attributes_hash, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/invoices/API_V1_Invoices_update_patch_3" target="_blank">
                /api/v1/contracts/:contract_id/invoices/:id
            </a>
        </td>
        <td>
            <code>client.invoices.update(id, attributes_hash, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>DELETE</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/invoices/API_V1_Invoices_destroy_delete_4" target="_blank">
                /api/v1/contracts/:contract_id/invoices/:id
            </a>
        </td>
        <td>
            <code>client.invoices.destroy(id, contract_id: id)</code>
        </td>
    </tr>
</table>

#### [Invoice Rules](https://app.billimatic.com.br/docs/api#!/invoice_rules)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/invoice_rules/API_V1_InvoiceRules_create_post_0" target="_blank">
                /api/v1/contracts/:contract_id/invoice_rules
            </a>
        </td>
        <td>
            <code>client.invoice_rules.create(attributes_hash, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/invoice_rules/API_V1_InvoiceRules_update_patch_1" target="_blank">
                /api/v1/contracts/:contract_id/invoice_rules/:id
            </a>
        </td>
        <td>
            <code>client.invoice_rules.update(id, attributes_hash, contract_id: id)</code>
        </td>
    </tr>
</table>

#### [Companies](https://app.billimatic.com.br/docs/api#!/companies)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/companies/API_V1_Companies_search_get_0" target="_blank">
                /api/v1/companies/search?cnpj=:cnpj
            </a>
        </td>
        <td>
            <code>client.companies.search(cnpj)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/companies/API_V1_Companies_create_post_1" target="_blank">
                /api/v1/companies
            </a>
        </td>
        <td>
            <code>client.companies.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/companies/API_V1_Companies_update_patch_2" target="_blank">
                /api/v1/companies/:id
            </a>
        </td>
        <td>
            <code>client.companies.update(id, attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>DELETE</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/companies/API_V1_Companies_destroy_delete_3" target="_blank">
                /api/v1/companies/:id
            </a>
        </td>
        <td>
            <code>client.companies.destroy(id)</code>
        </td>
    </tr>
</table>

#### [Service Items](https://app.billimatic.com.br/docs/api#!/service_items)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/service_items/API_V1_ServiceItems_search_get_0" target="_blank">
                /api/v1/service_items/search?name=:name
            </a>
        </td>
        <td>
            <code>client.service_items.search(name: name)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/service_items/API_V1_ServiceItems_create_post_1" target="_blank">
                /api/v1/service_items
            </a>
        </td>
        <td>
            <code>client.service_items.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/service_items/API_V1_ServiceItems_update_patch_2" target="_blank">
                /api/v1/service_items/:id
            </a>
        </td>
        <td>
            <code>client.service_items.update(id, attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>DELETE</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/service_items/API_V1_ServiceItems_destroy_delete_3" target="_blank">
                /api/v1/service_items/:id
            </a>
        </td>
        <td>
            <code>client.service_items.destroy(id)</code>
        </td>
    </tr>
</table>

## Url helpers

Some url helpers are available:

### Checkout

```ruby
Billimatic.url_helpers.checkout_url(token: "some-subscription-token")
```

### Subscription dashboard

```ruby
Billimatic.url_helpers.subscription_dashboard_url(token: "some-subscription-token")
```

### Change plan

```ruby
Billimatic.url_helpers.change_plan_url(token: "some-subscription-token", plan_id: 52)
```

## Callbacks

TODO

## Contributing

1. Fork it ( https://github.com/[my-github-username]/billimatic-client-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
