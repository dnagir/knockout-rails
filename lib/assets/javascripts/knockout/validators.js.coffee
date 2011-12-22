#= require knockout/validations

ko.Validations.validators =

  presence: (model, field, options) ->
    val = model[field]()
    isBlank = !val or val.toString().isBlank()

    if isBlank then options.message || "can't be blank" else null

  email: (model, field, options) ->
    val = model[field]()
    isValid = !val or val.toString().match /.+@.+\..+/
    unless isValid then options.message or "should be a valid email" else null

  custom: (model, field, options) ->
    # Treat options as a mandatory callback
    options.call(model, model)


