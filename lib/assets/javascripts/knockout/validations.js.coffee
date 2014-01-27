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
      validate_on = options['on']
      allowedByOnly = !only or only.call(me.subject)
      deniedByExcept = except and except.call(me.subject)
      deniedByStage = (validate_on == 'create' and me.subject.persisted()) or (validate_on == 'update' and not me.subject.persisted())

      shouldValidate = allowedByOnly and not deniedByExcept and not deniedByStage

      validator.call(me, me.subject, field, options) if shouldValidate

    validatorSubscriber.subscribe (newError) ->
      currentError = me.subject.errors[field]
      actualError = [currentError(), newError].exclude((x) -> !x).join(", ")
      me.subject.errors[field]( actualError or null)

    # Clear the error only once before the value gets changed
    validatorSubscriber.subscribe ->
      me.subject.errors[field](null)
    , me.subject, "beforeChange" if me._validations[field].isEmpty()

    # Enforce validation right after enabling it (disabled by default)
    skipValidation = @subject.constructor._skipValidationOnInitialization
    if skipValidation != undefined and not skipValidation
      validatorSubscriber.notifySubscribers( validatorSubscriber(), 'change')

    me._validations[field].push validatorSubscriber
    me


Validations =
  ClassMethods:
    # TODO delete skipValidationOnInitialization
    skipValidationOnInitialization: (enabled) ->
      @_skipValidationOnInitialization = enabled
    extended: -> @include Validations.InstanceMethods

  InstanceMethods:
    isValid: (parent = null) ->
      # Clear all validation errors
      @updateErrors {}

      # Run all validations
      if @validationContext
        for field, validatorSubscribers of @validationContext._validations
          for validatorSubscriber in validatorSubscribers
            validatorSubscriber.notifySubscribers(validatorSubscriber(), 'change') # run validators

      # Check errors
      return true unless @errors
      isValid = true
      for key, value of @errors
        unless Object.isEmpty value()
          isValid = false
          console.log @constructor.name + '.' + key + ': ' + value()

      # Check errors of related
      for rel in (@constructor.__relations ||= [])
        accessor = @[rel.fld]
        unless parent != null and accessor() == parent
          if rel.kind == 'has_many' or rel.kind == 'has_and_belongs_to_many'
            for elem in (accessor() || [])
              isValid = false unless elem.isValid(this)
          else
            isValid = false if accessor() and not accessor().isValid(this)

      return isValid

    enableValidations: ->
      return false unless @constructor.validates
      @validationContext = new ValidationContext(this)
      dsl = @validationContext.getDsl()
      @constructor.validates.call(dsl, this)
      true

ko.Validations = Validations
