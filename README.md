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

## Formtastic-knockout binding

KrzysztofMadejski: For purpose of my own project I've extended Formtastic and FormtasticBoostrap so it generates data-bind tags.

See this Gist: https://gist.github.com/KrzysztofMadejski/5301195

Try it: `= semantic_form_for SeatReservation.new, knockout: true`. It will generate form with data-bind attributes.
For errors to work you will need errors_bootstrap custom binding as well.

*formtastic_knockout.rb* should be put in *config/initializers/*
*custom.bindings.bootstrap.js* should be put in *app/assets/javascripts/knockout/*

*knockout* can be specified on both `form_for` and specific `input` lines. It can take input in one of three formats:

* true/false - enable/disable default bindings (you can set `knockout: true` on `semantic_form_for`, and then disable some of the inputs)
* Hash - it is merged with defaults, ie. `knockout: {submit: '$root.save_form', css: '$root.form_class($index())' }`
* String - overrides defaults, ie. `= f.input :name, knockout: 'css: compute_class'`

## Model Validations

**Note**: Please look at *Changes* section above.

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

    @presence      'password'
    @confirmation  'password' # Blanks allowed, need password_confirmation field

    # numericality:
    @numericality  'rating'
    @numericality  'rating', minimum: 1, maximum: 5

    # Inclusion/exclusion
    @inclusion   'subdomain', 'in': ["mine", "yours"]
    @exclusion   'subdomain', 'in': ["www", "www2"]

    @format      'code', 'with': /\d+/ # Regex validation, blanks allowed
    @length      'name', minimum: 3, maximum: 10 # Stringish value should be with the range

    # Custom message
    @presence    'name', message: 'give me a name, yo!'

    # Conditional validation - access model using `this`
    @presence    'name', only: -> @persisted(), except: -> @id() > 5

    # Same as above
    @presence    'name', 'on': 'update', except: -> @id() > 5

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
  @funky 'name', word: 'yakk'
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

  @upon 'beforeSave', ->
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

# CHANGES  1.0.1 > 2.0.0 by Krzysztof Madejski

This version is not fully compatible with original 1.0.1 (validations are rewritten and there were some small changes in model).

## Server-side errors handling

ActiveResource default convention to return errors in json is `{:errors => {:name => ["Name can't be blank"], :city => ["City can't be blank"]}}`. Knockout-rails now expects errors to be wrapped like that instead of simple `{field: error_list}` dictionary.

If you initialize an object using data with errors (`{name: 'bla', errors: ['bla forbidden']`) they will be treated as errors and not a field.

## Update object after save success

Server-side can compute some additional fields on model instance so it would be wise to update it on save success (HTTP 201 Created). Done!

## Deleting object

One of basic CRUD operations is now implemented. Just call `instance.delete()`. On success `id` will be nilled, so `instance.persisted()` will properly return `false`.

## Listing objects

And more REST just call `Model.all(param)` and you will get new observableArray from '/models'.


## Skip validation on initialization

I've had problem when creating new model instances (CRUD again) dynamically (`@reservations.push(new SeatReservation())`). Validations were invoked straight-on before user even managed to click anywhere. Now validations are skipped on object creation by default. You can bring back the previous behaviour using:

```coffee
class @SeatReservation extends ko.Model
  @skipValidationOnInitialization false
  ...
```

## Event callbacks

I've extended list of events and added instance-level callbacks (`model_instance.upon 'sayHi', -> alert 'hi'`).

Looking at skeary branch I've found very helpfull extending the list of events. Here goes the full supported list:

* beforeSave
* saveSuccess
* saveValidationError
* saveProcessingError
* beforeDelete
* deleteError
* deleteSuccess
* beforeAll
* allError
* allSuccess

Sometimes one need to bind events only to chosen objects instead of all model instances. For example to inform model-list-container about update success. So I've added instance-level callbacks:

```coffee
class @SeatReservation extends ko.Model
  @persistAt 'meal'
  @fields 'name', 'meal'

  # model-level callback
  @beforeSave ->
    @name = @name.trim

  # is the same as:
  @upon 'beforeSave', ->
    @name = @name.trim

class @SeatReservationListVM
  constructor: (json) ->
    @reservations = ko.observableArray()

    for jreservation in json
      do (jreservation) =>
        reservation = new SeatReservation(jreservation)

        # INSTANCE-level callback
        reservation.upon 'beforeSave', ->
          @name = @name + ' OLD'

        @reservations.push(reservation)
```

Maybe `afterSave` and `afterDelete` events (invoked always despite the result) could be heplful as well. If so, report an issue. Also, I was wondering if `saveSuccess` should have an argument specifying if model instance was created or updated.

## Railsy validations

When I first looked at knockout-rails I was like "Wooow, it even mimics rails ActiveRecord validations!". Now I see they are not perfect (nor are AR validation when I discovered later). I've rewritten all validators (dropping @email) to mimic (argument names) and behave like rails-one do. Specifically:

* You can always specify a message and allows_nil flag
* All validator attribues should mimic rails with few exceptions
  * `in` and `with` attributes are keywords in coffee and thus need to be escaped with quotes, ie.: `@exclusion 'type', 'in': ['T1', 'T2']`
  * `LengthValidator` custom message are placed inside hash `messages` (an example is few lines below)
  * `if` and `unless` options are both keywords, so I've left original `only` and `except` (it's still rails convention, though not for validators)
* You can use placeholders in messages, ie. `@exclusion 'type', within: ['T1', 'T2'], message: '%{value} is not allowed'`
* Custom messages are placed in additional `messages` hash, ie. `@length 'name', maximum: 10, messages: {too_short: 'maximum %{count} characters allowed'}`

## Rails2Coffee validation and field mapper

Tired of rewriting model validations in coffee to match those in AR models? Afraid that you will forget to rewrite them again after model changes? Introducing..

`seat_reservation.js.coffee.erb`

```erb
class @SeatReservation extends ko.Model
  @persistAt 'meal'
  <%= SeatReservation.knockout_fields %>

  @validates: ->
    <%= SeatReservation.knockout_validations %>
    ###
    Leave returned code in compiled js for debugging, inspecting skipped validators, etc.
    <%= SeatReservation.knockout_validations newline: true %>
    ###
```

`knockout_fields` accepts following options:
* `except` - list of filtered attributes. It defaults to `[:created_at, :updated_at]`. If you would like to have those use `SeatReservation.knockout_fields except: []`
* `only` - instead of blacklisting with `except` you can whitelist attributes
* `extra` - if you want to add few attributes you should use `extra` instead of whitelisting all fields

`knockout_validations` accepts `except` and `only` options:
```ruby
# USAGE only: {attribute: []} # include all
# USAGE only: {attribute: :validator_kind}
# USAGE only: {attribute: [:kind1, :kind2]}

# USAGE except: {attribute: []} # ignore all validators for attribute
# USAGE except: {attribute: :validator_kind}
# USAGE except: {attribute: [:kind1, :kind2]}
```

`knockout_validations` is skipping `validates_with CustomValidator` options and conditional validations (using `if` and `unless`) as one cannot automatically map ruby block to JS. `validates_each` block-based validations are also skipped. If you want to see what's skipped look at generated coffee code either trough `###` coffee block comments or simply by renaming file to `seat_reservation.js.erb`, so it's not processed by coffee compiler.

`knockout_validations` automatically maps EachValidator validations though you have to write its client-side js counterpart by yourself.

Having:

`app/validators/ReservationNameValidator.rb`

```ruby
class ReservationNameValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
     is_valid = false # implement
     record.errors[attribute] << "is invalid" unless is_valid
  end
end
```

and `app/models/seat_reservation.rb`

```ruby
class SeatReservation < ActiveRecord::Base
  # Attributes
  attr_accessible :name, :meal

  # Validations
  validates :name, reservation_name: true
end
```

`SeatReservation.knockout_validations` will produce `@reservation_name 'name', {}`

As `reservation_name` validator is custom you have to write it and bind to `ko.Validations.validators`:

```coffee
ko.Validations.validators.reservation_name = (model, field, options) ->
    val = model[field]()
    return if options.allow_nil and not val # allow_nil defaults to false

    is_valid = false # implement
    return if is_valid then null else "is invalid"
```

# License

[MIT] (http://www.opensource.org/licenses/mit-license.php)
