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

After you've referenced the `knockout` you can create your first persitent Model.

```coffee
class Page extends ko.Model
  @configure 'page' # This is enough to make save the model usng REST under `/pages` URL
```

Too simple. This model conforms to the response of [inherited_resources](https://github.com/josevalim/inherited_resources) Gem.


Now you can create the model in your HTML.
Not that we don't do a roundtrip to fetch the data as we already have it when rendering the page.

```haml
= content_for :script do
  :javascript
    jQuery(function(){
      // Create the viewModel with prefilled data
      window.page = new Page(#{@page.to_json});
      ko.applyBindings(window.page); // And bind everything
    });
```

Of course you can manipulate the object as you wish:

```coffee
page.name 'Updated page'
page.save()
# saves it to the server using PUT: /pages/123
page.name '' # Assign an invalid value that is validated on the server
request = page.save() # returns the jQuery Deferred, so you can chain into it when necessary
request.always (xhr, status) ->
  # The response is 422 with JSON: {name: ["invalid name", "should not be blank"]}
  # And now we have the errors set automatically!
  page.errors.name() # "invalid name, should not be blank"
```

Now let's see how we can show the validation errors on the page and bind everything together.

```haml

%form.page.formtastic{:data => {:bind =>'submit: save'}}
  %fieldset
    %ol
      %li.input.string
        %label.label{:for=>:page_name} Name
        %input#page_name{:type=>:text, :data=>{:bind=>'value: name'}}
        %span.inline-error{:data=>{:bind=>'visible: errors.name, text: errors.name'}}
```


# Development

## Help

- Source hosted at [GitHub](https://github.com/dnagir/knockout-rails)
- Report issues and feature requests to [GitHub Issues](https://github.com/dnagir/knockout-rails/issues)
- Ping me on Twitter for quicky thing [@dnagir](https://twitter.com/#!/dnagir)
- Look at the `HISTORY.md` file for current todo list and other details.


## Setup

Asuming you already cloned the repo in cd-d into it:

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
