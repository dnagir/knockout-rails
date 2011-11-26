#= require ios-checkboxes

ko.bindingHandlers.onoff =
  init: (element, valueAccessor, allBindingsAccessor) ->
    initialValue = ko.utils.unwrapObservable valueAccessor()
    $(element).prop('checked', initialValue).iphoneStyle
      handleMargin: 0
      containerRadius: 0
      resizeHandle: false
      resizeContainer: false
      checkedLabel: 'On'
      uncheckedLabel: 'Off'
      onChange: (el, checked) ->
        writer = valueAccessor()
        writer checked

  update: (element, valueAccessor) ->
    el = $(element)
    val = ko.utils.unwrapObservable valueAccessor()
    el.prop('checked', val)
