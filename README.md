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

* TODO

## Endpoints

TODO

## Callbacks

TODO

## Contributing

1. Fork it ( https://github.com/[my-github-username]/billimatic-client-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
