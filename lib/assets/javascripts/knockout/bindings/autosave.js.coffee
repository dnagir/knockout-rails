valOrDefault = (val, def) ->
  if val?
    ko.utils.unwrapObservable val
  else
    def

ko.bindingHandlers.autosave =
  init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
    form = $(element)
    form.submit (e) -> e.preventDefault()

    options = valueAccessor()
    [ifYes, ifNo, model] = [options.when, options.unless, options.model]

    model = options unless ifYes? or ifNo?

    throw "Pls provide either MODEL object or: {model: yourModel, when: optionalTrueCondition, unless: optionalFalseCondition}" unless model.save

    doSave = model.save.debounce(500) # Not too fast

    # subscribe to all notifications of all the observable fields of the model
    observables = Object.keys(model).filter((x)->ko.isObservable model[x]).map (x)->model[x]
    observables.forEach (o) -> o.subscribe ->
      ye = valOrDefault ifYes, true
      na = valOrDefault ifNo, false
      doSave() if ye and not na
