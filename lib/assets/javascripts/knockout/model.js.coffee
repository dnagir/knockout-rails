#=require jquery

# Module is taken from Spine.js
moduleKeywords = ['included', 'extended']
class Module
  @include: (obj) ->
    throw('include(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @::[key] = value
    obj.included?.apply(@)
    @

  @extend: (obj) ->
    throw('extend(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @[key] = value
    obj.extended?.apply(@)
    @
    
Events =
  ClassMethods:
    extended: ->
      @events ||= {}
      @include Events.InstanceMethods
    upon: (eventName, callback) ->
      @events[eventName] || = []
      @events[eventName].push callback
      this # Just to chain it if we need to

  InstanceMethods:
    trigger: (eventName, args...) ->
      events = @constructor.events
      handlers = events[eventName] || []
      callback.apply(this, args) for callback in handlers
      this # so that we can chain


Callbacks =
  ClassMethods:
    beforeSave: (callback) -> @upon('beforeSave', callback)

validators =
  presence: (model, field, options) ->
    val = model[field]()
    isBlank = !val or (val.toString().match /^\s*$/)

    if isBlank then "can't be blank" else null

  email: (model, field, options) ->
    if model[field]()? then "should be valid email" else null

class ValidationContext

  constructor: (@subject) ->

  getDsl: (source = validators)->
    dsl = {}
    me = this
    @wrapValidator(dsl, name, func) for name, func of source
    dsl

  wrapValidator: (dsl, name, func)->
    me = this
    dsl[name] = (fields..., options) ->
      unless typeof(options) is 'object'
        fields.push options
        options = {}
      me.setValidator(func, field, options) for field in fields
      dsl

  setValidator: (validator, field, options) ->
    me = this
    validatorSubscriber = ko.dependentObservable ->
      validator.call(me, me.subject, field, options)

    validatorSubscriber.subscribe (newError) ->
      me.subject.errors[field]( newError )

    me._validations ||= {}
    me._validations[field] ||= []
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


Ajax =
  ClassMethods:
    persistAt: (@className) ->
      @getUrl ||= (model) ->
        return model.getUrl(model) if model and model.getUrl
        collectionUrl = "/#{className.toLowerCase()}s"
        collectionUrl += "/#{model.id()}" if model?.id()
        collectionUrl
    extended: -> @include Ajax.InstanceMethods


  InstanceMethods:
    ignore:  -> []
    mapping: ->
      return @__ko_mapping__ if @__ko_mapping__
      mappable =
        ignore: @ignore()
      for k, v of this
        mappable.ignore.push k unless ko.isObservable(v)
      @__ko_mapping__ = mappable

    toJSON: -> ko.mapping.toJS @, @mapping()

    save: ->
      allowSaving = @isValid()
      return false unless allowSaving
      @trigger('beforeSave') # Consider moving it into the beforeSend or similar
      data = {}
      data[@constructor.className] =@toJSON()
      params =
        type: if @persisted() then 'PUT' else 'POST'
        dataType: 'json'
        beforeSend: (xhr)->
          token = $('meta[name="csrf-token"]').attr('content')
          xhr.setRequestHeader('X-CSRF-Token', token) if token
        url: @constructor.getUrl(@)
        contentType: 'application/json'
        context: this
        processData: false # jQuery tries to serialize to much, including constructor data
        data: JSON.stringify data
        statusCode:
          422: (xhr, status, errorThrown)->
            errorData = JSON.parse xhr.responseText
            console?.debug?("Validation error: ", errorData)
            @updateErrors(errorData)

      $.ajax(params)
        #.fail (xhr, status, errorThrown)-> console.error "fail: ", this
        .done (resp, status, xhr)-> @updateErrors {}
        #.always (xhr, status) -> console.info "always: ", this



class Model extends Module
  @extend Ajax.ClassMethods
  @extend Events.ClassMethods
  @extend Callbacks.ClassMethods
  @extend Validations.ClassMethods

  @fields: (fieldNames...) -> @fieldNames = fieldNames

  constructor: (json) ->
    me = this
    @set json
    @id ||= ko.observable()
    # Overly Heavy, heavy binding to `this`...
    @mapping().ignore.exclude('constructor').filter (v)->
        not v.startsWith('_') and Object.isFunction me[v]
      .forEach (fn) ->
        original = me[fn]
        me[fn] = original.bind me
        me._originals ||= {}
        me._originals[fn] = original

    @persisted = ko.dependentObservable -> !!me.id()

  set: (json) ->
    ko.mapping.fromJS json, @mapping(), @
    me = this
    @errors ||= {}
    ignores = @mapping().ignore
    availableFields = @constructor.fieldNames
    availableFields ||= @constructor.fields Object.keys(json) # Configure fields unless done manually

    #for key, value of json
    for key in availableFields when ignores.indexOf(key) < 0
      @[key] ||= ko.observable()
      @errors[key] ||= ko.observable()
    @enableValidations()
    @

  updateErrors: (errorData) ->
    for key, setter of @errors
      field = @errors[key]
      error = errorData[key]
      message = if error and error.join
          error.join(", ")
        else
          error
      setter( message ) if field
    @

  
# Export it all:
ko.Module = Module
ko.Model = Model
ko.Validations = Validations
ko.Events = Events
