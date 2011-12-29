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
class @Page extends ko.Model
  @persistAt 'page' # This is enough to save the model RESTfully to `/pages/{id}` URL
  @fields 'id', 'name', 'whatever' # This is optional and will be inferred if not used
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

## Model Validations

If you are using the model, you can also take advantage of the client-side validation framework.

The client side validation works similarly to the server-side validation.
This means there is only one place to check for errors, no matter where those are defined.

For example - `page.errors.name()` returns the error message for the `name` field for both client and server side validations.

The piece of code below should explain client-side validation, including some of the options.

```coffee
class @Page extends ko.Model
  @persistAt 'page'

  @validates: ->
    @acceptance  'agree_to_terms' # Value is truthy
    @presence    'name', 'body' # Non-empty, non-blank stringish value
    @email       'author' # Valid email, blanks allowed

    @presence      'password'
    @confirmation  'passwordConfirmation', {confirms: 'password'} # Blanks allowed

    # numericality:
    @numericality  'rating'
    @numericality  'rating', min: 1, max: 5

    # Inclusion/exclusion
    @inclusion   'subdomain', values: ["mine", "yours"]
    @exclusion   'subdomain', values: ["www", "www2"] 

    @format      'code', match: /\d+/ # Regex validation, blanks allowed
    @length      'name', min: 3, max: 10 # Stringish value should be with the range

    # Custom message
    @presence    'name', message: 'give me a name, yo!'

    # Conditional validation - access model using `this`
    @presence    'name', only: -> @persisted(), except: -> @id() > 5

    # Custom inline validation
    @custom 'name', (page) ->
      if (page.name() || '').indexOf('funky') < 0 then "should be funky" else null
```

It is recommended to avoid custom inline validations and create your own validators instead (and maybe submit it as a Pull Request):


```coffee
ko.Validations.validators.funky = (model, field, options) ->
  # options - is an optional set of options passed to the validator
  word = options.word || 'funky'
  if model[field]().indexOf(word) < 0 "should be #{word}" else null
```

so that you can use it like so:

```coffee
@validates: ->
  funky 'name', word: 'yakk'
```

Here's how you would check whether the model is valid or not (assuming presence validation on `name` field):

```coffee
page = new @Page name: ''
page.isValid() # false
page.errors.name() # "can't be blank"

page.name = 'Home'
page.isValid() # true
page.errors.name() # null

```

Every validator has its own set of options. But the following are applied to all of them (including yours):

- `only: -> truthy or falsy` - only apply the validation when the condition is truthy. `this` points to the model so you can access it.
- `except:` - is the opposite to only. Both `only` and `except` can be used, but you should make sure those are not mutually exclusive.


And at the end of this exercise, you can bind the errors using `data-bind="text: page.error.name"` or any other technique.

## Model Events

```coffee
class @Page extends ko.Model
  @persistAt 'page'

  # Subscribe to 'sayHi' event
  @upon 'sayHi', (name) ->
    alert name + @name

page = Page.new name: 'Home'
page.trigger 'sayHi', 'Hi '
# will show "Hi Home"

```


## Model Callbacks

The callbacks are just convenience wrappers over the predefined events.
Some of them are:

```coffee
class @Page extends ko.Model
  @persistAt 'page'

  @beforeSave ->
    @age = @birthdate - new Date()

# This would be similar to

class @Page extends ko.Model
  @persistAt 'page'

  @on 'beforeSave', ->
    @age = @birthdate - new Date()
```


## Bindings

This gem also includes useful bindings that you may find useful in your application.
For example, you can use `autosave` binding by requiring `knockout/bindings/autosave`.

Or if you want to include all of the bindings available, then require `knockout/bindings/all`.

The list of currently available bindings:

- `autosave` - automatically persists the model whenever any of its attributes change.
  Apply it to a `form` element. Examples: `autosave: page`, `autosave: {model: page, when: page.isEnabled, unless: viewModel.doNotSave }`. *NOTE*: It will not save when a model is not valid.
- `inplace` - converts the input elements into inplace editing with 'Edit'/'Done' buttons. Apply it on `input` elements similarly to the `value` binding.
- `color` - converts an element into a color picker. Apply it to a `div` element: `color: page.fontColor`. Depends on [pakunok](https://github.com/dnagir/pakunok) gem (specifically - its `colorpicker` asset).
- `onoff` - Converts checkboxes into iOS on/off buttons. Example: `onoff: page.isPublic`. It depends on [ios-chechboxes](https://github.com/dnagir/ios-checkboxes) gem.
- `animate` - runs the animation when dependent attributes change. Example: `animate: {width: quotaUsed, height: quotaUsed(), duration: 2000}`.
- `autocomplete` - supports jQuery UI autocomplete. Example: `autocomplete: {source: arrayOrObservableOrAnyObjectOrDeferred, select: observableToSetTheValueTo, label: 'nameOfTheFieldToDisplay'}`. The `source` can support `jQuery.Deferred` meaning that you can simply return the result of a `jQuery.ajax`.


Please see the specs for more detailed instruction on how to use the specific binding.

# Development

## Help

- Source hosted at [GitHub](https://github.com/dnagir/knockout-rails)
- Report issues and feature requests to [GitHub Issues](https://github.com/dnagir/knockout-rails/issues)
- Ping me on Twitter [@dnagir](https://twitter.com/#!/dnagir)
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
