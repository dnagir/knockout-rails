class ValidationContext

  constructor: (@subject) ->

  getDsl: (source = ko.Validations.validators) ->
    dsl = {}
    me = this
    @wrapValidator dsl, name, func for name, func of source
    dsl

  wrapValidator: (dsl, name, func)->
    me = this
    dsl[name] = (fields..., options) ->
      if typeof(options) is 'string'
        # Last argument isn't `options` - it's a field
        fields.push options
        options = {}
      me.setValidator(func, field, options) for field in fields
      dsl

  setValidator: (validator, field, options) ->
    me = this
    me._validations ||= {}
    me._validations[field] ||= []

    validatorSubscriber = ko.dependentObservable ->
      validator.call(me, me.subject, field, options)

    validatorSubscriber.subscribe (newError) ->
      err = me.subject.errors[field]
      me.subject.errors[field]( [err(), newError].compact().join(", ")  )

    # Clear the error only once before the value gets changed
    validatorSubscriber.subscribe ->
        me.subject.errors[field](null)
      , me.subject, "beforeChange" if me._validations[field].isEmpty()

    me._validations[field].push validatorSubscriber
    me


Validations =
  ClassMethods:
    extended: -> @include Validations.InstanceMethods

  InstanceMethods:
    isValid: ->
      return true unless @errors
      for key, value of @errors
        return false unless Object.isEmpty value()
      return true

    enableValidations: ->
      return false unless @constructor.validates
      @validationContext = new ValidationContext(this)
      dsl = @validationContext.getDsl()
      @constructor.validates.call(dsl, this)
      true

ko.Validations = Validations

ko.Validations.validators =

  presence: (model, field, options) ->
    val = model[field]()
    isBlank = !val or val.toString().isBlank()

    if isBlank then options.message || "can't be blank" else null

  email: (model, field, options) ->
    if model[field]()? then "should be valid email" else null

  custom: (model, field, options) ->
    # Treat options as a mandatory callback
    options.call(model, model)


