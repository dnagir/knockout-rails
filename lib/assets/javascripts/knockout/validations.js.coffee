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
      {only, except} = options
      allowedByOnly = !only or only.call(me.subject)
      deniedByExcept = except and except.call(me.subject)

      shouldValidate = allowedByOnly and not deniedByExcept

      validator.call(me, me.subject, field, options) if shouldValidate

    validatorSubscriber.subscribe (newError) ->
      currentError = me.subject.errors[field]
      actualError = [currentError(), newError].exclude((x) -> !x).join(", ")
      me.subject.errors[field]( actualError or null)

    # Clear the error only once before the value gets changed
    validatorSubscriber.subscribe ->
        me.subject.errors[field](null)
      , me.subject, "beforeChange" if me._validations[field].isEmpty()

    # Enforce validation right after enabling it
    validatorSubscriber.notifySubscribers( validatorSubscriber(), 'change')

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
