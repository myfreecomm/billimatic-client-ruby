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

* [Organizations API](https://myfreecomm.github.io/billimatic-api-docs/#organizacoes) as `client.organizations`
* [Plans API](https://myfreecomm.github.io/billimatic-api-docs/#planos) as `client.plans`
* [Subscriptions API](https://myfreecomm.github.io/billimatic-api-docs/#assinaturas) as `client.subscriptions`
* [Contracts API](https://myfreecomm.github.io/billimatic-api-docs/#contratos) as `client.contracts`
* [Invoices API](https://myfreecomm.github.io/billimatic-api-docs/#faturamentos) as `client.invoices`
* [Invoice Templates API](https://myfreecomm.github.io/billimatic-api-docs/#modelos-de-faturamento) as `client.invoice_templates`
* [Invoice Rules API](https://myfreecomm.github.io/billimatic-api-docs/#regras-de-faturamento) as `client.invoice_rules`
* [Companies API](https://myfreecomm.github.io/billimatic-api-docs/#empresas) as `client.companies`
* [People API](https://myfreecomm.github.io/billimatic-api-docs/#pessoas) as `client.people`
* [Service Items API](https://myfreecomm.github.io/billimatic-api-docs/#servicos) as `client.service_items`

## Endpoints

#### [Organizations](https://myfreecomm.github.io/billimatic-api-docs/#organizacoes)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#busca-organizacao" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cria-organizacao" target="_blank">
                /api/v1/organizations
            </a>
        </td>
        <td>
            <code>client.organizations.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>PUT</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#atualiza-organizacao" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#exclui-organizacao" target="_blank">
                /api/v1/organizations/:id
            </a>
        </td>
        <td>
            <code>client.organizations.destroy(id)</code>
        </td>
    </tr>
</table>

#### [Plans](https://myfreecomm.github.io/billimatic-api-docs/#planos)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#lista-plano-s" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cria-plano" target="_blank">
                /api/v1/organizations/:organization_id/plans
            </a>
        </td>
        <td>
            <code>client.plans.create(attributes_hash, organization_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PUT</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#atualiza-plano" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#exclui-plano" target="_blank">
                /api/v1/organizations/:organization_id/plans/:id
            </a>
        </td>
        <td>
            <code>client.plans.destroy(id, organization_id: id)</code>
        </td>
    </tr>
</table>

#### [Subscriptions](https://myfreecomm.github.io/billimatic-api-docs/#assinaturas)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#detalhes-de-assinaturas" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cria-assinatura" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#checkout-de-assinatura" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#trocas-de-plano-de-assinaturas" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#trocas-de-forma-de-pagamento-em-assinaturas" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cancelamento-de-assinatura" target="_blank">
                /api/v1/subscriptions/:token/cancel
            </a>
        </td>
        <td>
            <code>
                # cancel_date and cancel_reason are optional arguments
                <br>
                client.subscriptions.cancel(token: token, cancel_date: date, cancel_reason: reason)
            </code>
        </td>
    </tr>
</table>

#### [Contracts](https://myfreecomm.github.io/billimatic-api-docs/#contratos)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#lista-contrato-s" target="_blank">
                /api/v1/organizations/:organization_id/contracts
            </a>
        </td>
        <td>
            <code>client.contracts.list(organization_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#detalhes-contrato" target="_blank">
                /api/v1/organizations/:organization_id/contracts/:id
            </a>
        </td>
        <td>
            <code>client.contracts.show(id, organization_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#busca-contrato" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cria-contrato" target="_blank">
                /api/v1/contracts
            </a>
        </td>
        <td>
            <code>client.contracts.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>PUT</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#atualizar-contrato" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#exclui-contrato" target="_blank">
                /api/v1/contracts/:id
            </a>
        </td>
        <td>
            <code>client.contracts.destroy(id)</code>
        </td>
    </tr>
</table>

#### [Invoices](https://myfreecomm.github.io/billimatic-api-docs/#faturamentos)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#buscar-faturamento" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#faturamentos-inadimplentes" target="_blank">
                /api/v1/contracts/:contract_id/invoices/late
            </a>
        </td>
        <td>
            <code>client.invoices.late(contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#bloqueia-faturamento" target="_blank">
                /api/v1/contracts/:contract_id/invoices/:id/block
            </a>
        </td>
        <td>
            <code>client.invoices.block(id, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#aprova-faturamento" target="_blank">
                /api/v1/contracts/:contract_id/invoices/:id/approve
            </a>
        </td>
        <td>
            <code>client.invoices.approve(id, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cria-faturamento" target="_blank">
                /api/v1/contracts/:contract_id/invoices
            </a>
        </td>
        <td>
            <code>client.invoices.create(attributes_hash, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#detalhes-faturamento" target="_blank">
                /api/v1/contracts/:contract_id/invoices/:id
            </a>
        </td>
        <td>
            <code>client.invoices.show(id, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PUT</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#atualiza-faturamento" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#exclui-faturamento" target="_blank">
                /api/v1/contracts/:contract_id/invoices/:id
            </a>
        </td>
        <td>
            <code>client.invoices.destroy(id, contract_id: id)</code>
        </td>
    </tr>
</table>

#### [Invoice Templates](https://myfreecomm.github.io/billimatic-api-docs/#modelos-de-faturamento)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#lista-modelo-de-faturamento-s" target="_blank">
                /api/v1/organizations/:organization_id/invoice_templates
            </a>
        </td>
        <td>
            <code>client.invoice_templates.list(organization_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#detalhes-modelo-de-faturamento" target="_blank">
                /api/v1/organizations/:organization_id/invoice_templates/:id
            </a>
        </td>
        <td>
            <code>client.invoice_templates.show(id, organization_id: id)</code>
        </td>
    </tr>
</table>

#### [Invoice Rules](https://myfreecomm.github.io/billimatic-api-docs/#regras-de-faturamento)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#lista-regra-s-faturamento-s" target="_blank">
                /api/v1/contracts/:contract_id/invoice_rules
            </a>
        </td>
        <td>
            <code>client.invoice_rules.list(contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cria-regra-faturamento" target="_blank">
                /api/v1/contracts/:contract_id/invoice_rules
            </a>
        </td>
        <td>
            <code>client.invoice_rules.create(attributes_hash, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PUT</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#atualiza-regra-faturamento" target="_blank">
                /api/v1/contracts/:contract_id/invoice_rules/:id
            </a>
        </td>
        <td>
            <code>client.invoice_rules.update(id, attributes_hash, contract_id: id)</code>
        </td>
    </tr>
    <tr>
        <td><code>DELETE</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#exclui-regra-faturamento" target="_blank">
                /api/v1/contracts/:contract_id/invoice_rules/:id
            </a>
        </td>
        <td>
            <code>client.invoice_rules.destroy(id, contract_id: id)</code>
        </td>
    </tr>
</table>

#### [Companies](https://myfreecomm.github.io/billimatic-api-docs/#empresas)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#busca-empresa" target="_blank">
                /api/v1/companies/search?cnpj=:cnpj
            </a>
        </td>
        <td>
            <code>client.companies.search(cnpj)</code>
        </td>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#lista-empresa-s" target="_blank">
                /api/v1/companies
            </a>
        </td>
        <td>
            <code>client.companies.list</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cria-empresa" target="_blank">
                /api/v1/companies
            </a>
        </td>
        <td>
            <code>client.companies.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#detalhes-empresa" target="_blank">
                /api/v1/companies/:id
            </a>
        </td>
        <td>
            <code>client.companies.show(id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PATCH</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#atualiza-empresa" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#exclui-empresa" target="_blank">
                /api/v1/companies/:id
            </a>
        </td>
        <td>
            <code>client.companies.destroy(id)</code>
        </td>
    </tr>
</table>

#### [People](https://myfreecomm.github.io/billimatic-api-docs/#pessoas)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#busca-pessoa" target="_blank">
                /api/v1/people/search?cpf=:cpf
            </a>
        </td>
        <td>
            <code>client.people.search(cpf: cpf)</code>
        </td>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#lista-pessoa-s" target="_blank">
                /api/v1/people
            </a>
        </td>
        <td>
            <code>client.people.list</code>
        </td>
    </tr>
    <tr>
        <td><code>POST</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cria-pessoa" target="_blank">
                /api/v1/people
            </a>
        </td>
        <td>
            <code>client.people.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#detalhes-pessoa" target="_blank">
                /api/v1/people/:id
            </a>
        </td>
        <td>
            <code>client.people.show(id)</code>
        </td>
    </tr>
    <tr>
        <td><code>PUT</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#atualiza-pessoa" target="_blank">
                /api/v1/people/:id
            </a>
        </td>
        <td>
            <code>client.people.update(id, attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>DELETE</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#exclui-pessoa" target="_blank">
                /api/v1/people/:id
            </a>
        </td>
        <td>
            <code>client.people.destroy(id)</code>
        </td>
    </tr>
</table>

#### [Service Items](https://myfreecomm.github.io/billimatic-api-docs/#servicos)

<table>
    <tr>
        <th>HTTP method</th>
        <th>Endpoint</th>
        <th>Client method</th>
    </tr>
    <tr>
        <td><code>GET</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#busca-servico" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#cria-servico" target="_blank">
                /api/v1/service_items
            </a>
        </td>
        <td>
            <code>client.service_items.create(attributes_hash)</code>
        </td>
    </tr>
    <tr>
        <td><code>PUT</code></td>
        <td>
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#atualiza-servico" target="_blank">
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
            <a href="https://myfreecomm.github.io/billimatic-api-docs/#exclui-servico" target="_blank">
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
