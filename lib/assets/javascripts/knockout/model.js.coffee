#=require jquery
#=require knockout/validations
#=require knockout/validators

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
      @events[eventName] ||= []
      @events[eventName].push callback
      this # Just to chain it if we need to

  InstanceMethods:
    trigger: (eventName, args...) ->
      cevents = @constructor.events
      chandlers = cevents[eventName] || []
      callback.apply(this, args) for callback in chandlers

      ievents = @events || {}
      ihandlers = ievents[eventName] || []
      callback.apply(this, args) for callback in ihandlers

      this # so that we can chain

    upon: (eventName, callback) ->
      @events ||= {}
      @events[eventName] ||= []
      @events[eventName].push callback
      this # Just to chain it if we need to


Callbacks =
  ClassMethods:
    beforeSave: (callback) -> @upon('beforeSave', callback)
    saveSuccess: (callback) -> @upon('saveSuccess', callback)
    saveValidationError: (callback) -> @upon('saveValidationError', callback) # server validation errors
    saveProcessingError: (callback) -> @upon('saveProcessingError', callback)

    beforeDelete: (callback) -> @upon('beforeDelete', callback)
    deleteError: (callback) -> @upon('deleteError', callback)
    deleteSuccess: (callback) -> @upon('deleteSuccess', callback)


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
    # TODO Events should not be exposed like this
    # TODO Persisted - czy obsługuje flagę destroyed?
    ignore:  -> ['errors', 'events', 'persisted']
    mapping: ->
      # return @__ko_mapping__ if @__ko_mapping__ # removed, because it didn't allowed adding new fields on object
      # TODO should be three options: 1) send original fields (given on initialization), 2) send fields (declared with @fields), or 3) send all observables
      # original implementation was behaving as (1), now it behaves as (3), altough (2) could be quite helpful to choose a static set
      mappable =
        ignore: @ignore()
      for k, v of this
        mappable.ignore.push k unless ko.isObservable(v)
      @__ko_mapping__ = mappable

    toJSON: -> ko.mapping.toJS @, @mapping()

    delete: ->
      return false unless @persisted()
      @trigger('beforeDelete') # TODO

      data = {id: @id}

      params =
        type: 'DELETE'
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
            @updateErrors(errorData.errors)

      $.ajax(params)
        .fail (xhr, status, errorThrown)->
          @trigger('deleteError', errorThrown, xhr, status) if xhr.status == 422
          @trigger('deleteError', errorThrown, xhr, status) if xhr.status != 422

        .done (resp, status, xhr)->
          @id(null)
          @trigger('deleteSuccess', resp, xhr, status)

    save: ->
      @validateAllFields()
      return false unless @isValid()

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
            @updateErrors(errorData.errors)

      $.ajax(params)
        .fail (xhr, status, errorThrown)->
          @trigger('saveValidationError', errorThrown, xhr, status) if xhr.status == 422
          @trigger('saveProcessingError', errorThrown, xhr, status) if xhr.status != 422

        .done (resp, status, xhr)->
          if xhr.status == 201 # Created
            @set resp

          @updateErrors {}
          @trigger('saveSuccess', resp, xhr, status)

        #.always (xhr, status) -> console.info "always: ", this



class Model extends Module
  @extend Ajax.ClassMethods
  @extend Events.ClassMethods
  @extend Callbacks.ClassMethods
  @extend ko.Validations.ClassMethods

  @fields: (fieldNames...) ->
    fieldNames = fieldNames.flatten() # when a single arg is given as an array
    @fieldNames = fieldNames

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
    @enableValidations()

  set: (json = {}) ->
    me = this
    ko.mapping.fromJS json, @mapping(), @
    @errors ||= {}
    ignores = @mapping().ignore
    availableFields = @constructor.fieldNames
    availableFields ||= @constructor.fields Object.keys(json) # Configure fields unless done manually

     # key is local
    for key in availableFields when ignores.indexOf(key) < 0
      @[key] ||= ko.observable()
      @errors[key] ||= ko.observable()

    # initialize server-side given errors
    if json.errors
      @updateErrors json.errors

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
ko.Events = Events
