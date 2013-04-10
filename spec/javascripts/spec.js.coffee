#=require knockout
#=require_tree ./support
#=require knockout/model_mapping_spec
#=require knockout/model_nested_spec
# require_tree ./

beforeEach ->
  clearAjaxRequests()

  # Custom knockout matchers
  koMatchers = {
  toBeObservable: ->
    @message = =>
      "Expected " + @actual + (if @isNot then " not" else "") + " to be observable"
    ko.isObservable @actual

  toBeObservableArray: ->
    @message = =>
      "Expected " + @actual + (if @isNot then " not" else "") + " to be observable array"
    ko.isObservable @actual and @actual.destroyAll != undefined

  toBeInstanceOf: (className) ->
    @message = =>
      "Expected " + type(@actual) + " {" + @actual + "}" + (if @isNot then " not" else "") + " to be instance of " + className
    type(@actual) == className
  }

  @addMatchers koMatchers

# Similar to js typeof, but returns class names for prototyped objects
window.type = (obj) ->
  if obj == undefined or obj == null
    return String obj
  className = obj.constructor.name
  if "Boolean Number String Function Array Date RegExp Object".split(" ").indexOf(className) != -1
    return className.toLowerCase()

  return className