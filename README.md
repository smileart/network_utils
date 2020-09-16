# 🛠 NetworkUtils

<p align="center">
  <img width="360" title="logo" src ="./img/network_utils.png" />
</p>

> A set of convenient network utils utils to get URL info before downloading a resource, work with ports, etc.
> [![Build Status](https://travis-ci.org/smileart/network_utils.svg?branch=master)](https://travis-ci.org/smileart/network_utils)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'network_utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install network_utils

## Usage

```ruby
# NetworkUtils::UrlInfo

info = NetworkUtils::UrlInfo.new('https://www.wikipedia.org')
info.valid?           # => true
info.valid_online?    # => true
info.headers          # { 'content-type': 100500, … }
info.is?([:text, 'text/html', 'application/xml', 'text/csv'])
info.content_type     # => 'text/html'
info.size             # => 100500
info.is?('text/html') # => true
info.is?(:image).     # => false
```

```ruby
# NetworkUtils::Port

NetworkUtils::Port.random       # => 50200
NetworkUtils::Port.random_free  # => 65000

NetworkUtils::Port.available?(65000) # => true
NetworkUtils::Port.free?(50200)      # => false

NetworkUtils::Port.opened?(50200)    # => true
NetworkUtils::Port.occupied?(65000)  # => false

NetworkUtils::Port.name(8080)        # => ["http-alt"]
NetworkUtils::Port.service(8080)     # => [
                                     #       {:name=>"http-alt", :port=>8080, :protocol=>:udp, :description=>"HTTP Alternate (see port 80)"},
                                     #       {:name=>"http-alt", :port=>8080, :protocol=>:tcp, :description=>"HTTP Alternate (see port 80)"}
                                     #    ]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smileart/network_utils. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NetworkUtils project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/smileart/network_utils/blob/master/CODE_OF_CONDUCT.md).
