runAnimation = (element, valueAccessor) ->
    flat = valueAccessor()

    optionKeys = ['duration', 'easing', 'complete', 'step', 'queue', 'specialEasing']

    properties = {}
    Object.keys(flat).exclude(optionKeys).forEach (key) ->
      properties[key] = ko.utils.unwrapObservable flat[key]

    options = {}
    optionKeys.forEach (key) ->
      options[key] = flat[key] if flat[key]?

    $(element).animate properties, options

ko.bindingHandlers.animate =
  init: runAnimation
  update: runAnimation

