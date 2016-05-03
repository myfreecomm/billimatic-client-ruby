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
  config.url = 'https://sandbox.billimatic.com.br/api/v1' # defaults to 'https://app.billimatic.com.br/api/v1'
  config.user_agent = 'My App v1.0' # optional, but you should pass a custom user-agent identifying your app
end
```

## Usage

##### Given your token, create an instance of Billimatic::Client, as below:

```ruby
client = Billimatic.client("YOUR_TOKEN_HERE")
```

##### Now you have acess to every API endpoint:

* [Companies API](https://app.billimatic.com.br/docs/api#!/companies) as `client.companies`
* [Plans API](https://app.billimatic.com.br/docs/api#!/plans) as `client.plans`
* [Subscriptions API](https://app.billimatic.com.br/docs/api#!/subscriptions) as `client.subscriptions`

## Endpoints

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
            <code>client.plans.list(organization_id: organization_id)</code>
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
            <code>client.subscriptions.show(token: subscription_token)</code>
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
        <td><code>PATCH</code></td>
        <td>
            <a href="https://app.billimatic.com.br/docs/api#!/subscriptions/API_V1_Subscriptions_cancel_patch_0" target="_blank">
                /api/v1/subscriptions/:token/cancel
            </a>
        </td>
        <td>
            <code>client.subscriptions.cancel(token: subscription_token)</code>
        </td>
    </tr>
</table>

## Callbacks

TODO

## Contributing

1. Fork it ( https://github.com/[my-github-username]/billimatic-client-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
