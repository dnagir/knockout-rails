# Knockout - easily use Knockout.js from the Rails app

If you have any questions please contact me [@dnagir](http://www.ApproachE.com).

This provides a set of conveniences for you to use more like Backbone or Spine, but still fully leveraging KnockoutJS.

# Install

Add it to your Rails application's `Gemfile`:

```ruby
gem 'knockout-rails'
```

Then `bundle install`.

Reference `knockout` from your JavaScript as you normally do with Rails 3.1 Assets Pipeline.


# Usage

## Model

After you've referenced the `knockout` you can create your first persistent Model.

```coffee
class Page extends ko.Model
  @configure 'page' # This is enough to save the model RESTfully to `/pages/{id}` URL
```

Too simple. This model conforms to the response of [inherited_resources](https://github.com/josevalim/inherited_resources) Gem.


Now you can create the model in your HTML.
*Note* that we don't do a roundtrip to fetch the data as we already have it when rendering the view.

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
page.save() # saves it to the server using PUT: /pages/123
page.name '' # Assign an invalid value that is validated on the server
request = page.save() # returns the jQuery Deferred, so you can chain into it when necessary
request.always (xhr, status) ->
  # The response is 422 with JSON: {name: ["invalid name", "should not be blank"]}
  # And now we have the errors set automatically!
  page.errors.name() # "invalid name, should not be blank"
  # even more than that, errors are already bound and shown in the HTML (see the view below)
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

## Bindings

This gem also includes useful bindings that you may require from your application.
For example, you can use `autosave` binding by requiring `knockout/bindings/autosave`.

Please see the specs for more detailed instruction on how to use specific binding.

The list of currently available bindings:

- `autosave` - automatically persists the model whenever any of its attributes change.
  Apply it to a `form` element. Examples: `autosave: page`, `autosave: {model: page, when: page.isEnabled, unless: viewModel.doNotSave }`.
- `inplace` - converts the input elements into inplace editing with 'Edit'/'Done' buttons. Apply it on `input` elements similarly to the `value` binding.
- `color` - converts an element into a color picker. Apply it to a `div` element: `color: page.fontColor`. Depends on [pakunok](https://github.com/dnagir/pakunok) gem (specifically - its `colorpicker` asset).
- `onoff` - Converts checkboxes into iOS on/off buttons. Example: `onoff: page.isPublic`. It depends on [ios-chechboxes](https://github.com/dnagir/ios-checkboxes) gem.

# Development

## Help

- Source hosted at [GitHub](https://github.com/dnagir/knockout-rails)
- Report issues and feature requests to [GitHub Issues](https://github.com/dnagir/knockout-rails/issues)
- Ping me on Twitter for quickly thing [@dnagir](https://twitter.com/#!/dnagir)
- Look at the `HISTORY.md` file for current TODO list and other details.


## Setup

Assuming you already cloned the repo in cd-d into it:

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


Pull requests are very welcome, but please include the specs! It's extremely easy to write those!

# License

[MIT] (http://www.opensource.org/licenses/mit-license.php)
