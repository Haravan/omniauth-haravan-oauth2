[![Build Status](https://api.travis-ci.org/Haravan/omniauth-haravan-oauth2.png?branch=master)](http://travis-ci.org/Haravan/omniauth-haravan-oauth2)

# OmniAuth Haravan

Haravan OAuth2 Strategy for OmniAuth 1.0.

## Installing

Add to your `Gemfile`:

```ruby
gem 'omniauth-haravan-oauth2'
```

Then `bundle install`.

## Usage

`OmniAuth::Strategies::Haravan` is simply a Rack middleware. Read [the OmniAuth 1.0 docs](https://github.com/intridea/omniauth) for detailed instructions.

Here's a quick example, adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :haravan, ENV['SHOPIFY_API_KEY'], ENV['SHOPIFY_SHARED_SECRET']
end
```

## Configuring

You can configure the scope, which you pass in to the `provider` method via a `Hash`:

* `scope`: A comma-separated list of permissions you want to request from the user. See [the Haravan API docs](http://docs.haravan.com/api/tutorials/oauth) for a full list of available permissions.

* `setup`: A lambda which dynamically sets the `site`. You must initiate the OmniAuth process by passing in a `shop` query parameter of the shop you're requesting permissions for. Ex. http://myapp.com/auth/haravan?shop=example.myharavan.com

For example, to request `read_products`, `read_orders` and `write_content` permissions and display the authentication page:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :haravan, ENV['SHOPIFY_API_KEY'], ENV['SHOPIFY_SHARED_SECRET'],
            :scope => 'read_products,read_orders,write_content',
            :setup => lambda { |env| params = Rack::Utils.parse_query(env['QUERY_STRING'])
                                     env['omniauth.strategy'].options[:client_options][:site] = "https://#{params['shop']}" }
end
```

## Authentication Hash

Here's an example *Authentication Hash* available in `request.env['omniauth.auth']`:

```ruby
{
  :provider => 'haravan',
  :credentials => {
    :token => 'afasd923kjh0934kf', # OAuth 2.0 access_token, which you store and use to authenticate API requests
  }
}
```

## License

Copyright (c) 2012 by Haravan Inc

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
