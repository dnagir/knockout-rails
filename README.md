# Knockout - easily use Knockout.js from the Rails app

If you have any questions please contact me [@dnagir](http://www.ApproachE.com).

TODO: do describe properly

# Install

Add it to your Rails application's `Gemfile`:

```ruby
gem 'knockout'
```

Then `bundle install`.

Reference `knockout` from your JavaScript as you normally do.


# Usage

TODO: Describe

- Models
- Rails integration
- bindings
- observables


# Development

- Source hosted at [GitHub](https://github.com/dnagir/knockout-rails)
- Report issues and feature requests to [GitHub Issues](https://github.com/dnagir/knockout-rails/issues)

Setup (asuming you already cloned the repo in cd-d into it):

```bash
bundle install
# Now run the Ruby specs
bundle exec rspec spec/
# Now start JavaScript server for specs:
cd spec/dummy
bundle exec rails s
# go to http://localhost:3000/jasmine to see the results
```

Now you can go to `spec/javascripts` and start writing your specs and then modify stuff in `lib/assets/javascripts` to pass those.


Pull requests are very welcome, but please include the specs.

# License

TODO
