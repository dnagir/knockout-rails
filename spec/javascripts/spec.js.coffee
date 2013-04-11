#=require knockout
#=require_tree ./support
#=require knockout/model_mapping_spec
#=require knockout/model_relations_spec
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
    ko.isObservableArray(@actual)

  toBeInstanceOf: (className) ->
    type = kor.utils.getType(@actual)

    @message = =>
      "Expected " + type + " {" + @actual + "}" + (if @isNot then " not" else "") + " to be instance of " + className
    type == className
  }

  @addMatchers koMatchers
