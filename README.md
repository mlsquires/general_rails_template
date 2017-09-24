# Rails Application Template

Loosely Based on the rails template at: https://github.com/Skookum/uu-rails-api-template

* Rspec, Guard, Pry (byebug), SimpleCov
* Puma

The template will generate the Rspec files and initialize guard.

## How to Use

    rails new service_name -m https://raw.githubusercontent.com/mlsquires/general_rails_template/master/rails_template.rb

or

    rails new app_name -m <path-to>/rails_template.rb


Once the app exists

    cd app_name

And then you can:

    guard

## Routes
This template adds a `/health`  route that points to `health#index`. This is the health check endpoint that should make sure dependent servics are responding, etc. It's also known as a [canary endpoint](http://byterot.blogspot.com/2014/11/health-endpoint-in-design-slippery-rest-design-canary-endpoint-hysterix-asp-net-web.html). It should return JSON and be secured with an API token.

## TODO
