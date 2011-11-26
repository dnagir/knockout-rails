#= require pakunok/colorpicker

valOf = (va)-> ko.utils.unwrapObservable(va()) or ''

picker =
  init: (element, valueAccessor) ->
    val = valOf valueAccessor
    el = $(element)
    el.addClass('color').css('backgroundColor', val).ColorPicker
      color: val
      onChange: (hsb, hex, rgb) ->
        newVal = "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})"
        valueAccessor() newVal

  update: (element, valueAccessor) ->
    newValue = valOf valueAccessor
    $(element).css('backgroundColor', newValue)



ko.bindingHandlers.color = picker
