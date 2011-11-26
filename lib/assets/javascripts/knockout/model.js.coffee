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
    

Ajax =
  ClassMethods:
    configure: (@className) ->
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

  constructor: (json) ->
    me = this
    @set json
    @id ||= ko.observable()
    @mapping().ignore.exclude('constructor').filter (v)->
        not v.startsWith('_') and Object.isFunction me[v]
      .forEach (fn) ->
        original = me[fn]
        me[fn] = original.bind me
        me._originals ||= {}
        me._originals[fn] = original

    @persisted = ko.dependentObservable -> !!me.id()

  proxy: -> @mapping().ignore

  set: (json) ->
    ko.mapping.fromJS json, @mapping(), @
    me = this
    @errors ||= {}
    ignores = @mapping().ignore
    for key, value of this
      @errors[key] ||= ko.observable() unless ignores.indexOf(key) >= 0
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
