#= require knockout/validations

ko.Validations.validators =
  acceptance: (model, field, options) ->
    val = model[field]()

    return null if not val and options.allow_nil in [true, undefined] # allow_nil defaults to true

    accepted = if options.accept then val == options.accept else val
    unless accepted then options.message || "must be accepted" else null

  presence: (model, field, options) ->
    val = model[field]()
    isBlank = !val or val.toString().isBlank()
    if isBlank then options.message || "can't be blank" else null

  confirmation: (model, field, options) ->
    confirmationField = options.confirmedBy || field + '_confirmation'
    orig = model[field]()
    confirmation = model[confirmationField]()
    if confirmation and orig != confirmation then options.message or "doesn’t match confirmation" else null

  numericality: (model, field, options) ->
    # Rails is missing functionality for NumericalityValidator: cannot specify custom messages for different conditions like in length
    # Here you can specify them in options.messages.<custom_key>, ie. options.messages.greater_than

    val = model[field]()
    return if options.allow_nil and not val # allow_nil defaults to false

    numericParts = val.toString().trim().match /^([+-]?\d+)(\.\d+)?$/ if val
    return options.message || options.messages.not_a_number || "is not a number" unless numericParts

    isFloat = numericParts[2] != undefined
    value = parseFloat(val)
    format = (msg, value, count = null) ->
      msg.replace(/%{count}/g, count).replace(/%{value}/g, value)

    custom_message = options.messages || {}

    # Rails prefer default message rather than custom keys which I find quite unintuitive, but.. let's stick to it
    return format(options.message || custom_message.not_an_integer || "must be an integer", val) if (options.only_integer or options.odd or options.even) and isFloat
    return format(options.message || custom_message.odd || "must be odd", val) if options.odd and value % 2 == 0
    return format(options.message || custom_message.even || "must be even", val) if options.even and value % 2 == 1
    return format(options.message || custom_message.greater_than || "must be greater than %{count}", val, options.greater_than) if options.greater_than and value <= options.greater_than
    return format(options.message || custom_message.less_than || "must be less than %{count}", val, options.less_than) if options.less_than and value >= options.less_than
    return format(options.message || custom_message.greater_than_or_equal_to || "must be greater than or equal to %{count}", val, options.greater_than_or_equal_to) if options.greater_than_or_equal_to and value < options.greater_than_or_equal_to
    return format(options.message || custom_message.less_than_or_equal_to || "must be less than or equal to %{count}", val, options.less_than_or_equal_to) if options.less_than_or_equal_to and value > options.less_than_or_equal_to
    return format(options.message || custom_message.equal_to || "must be equal to %{count}", val, options.equal_to) if options.equal_to and value != options.equal_to

    return null # Ca va!

  inclusion: (model, field, options) ->
    values = options['in'] || options.within
    throw "Please specify the values {in: [1, 2, 5]}" unless values
    format = (msg, value) ->
      msg.replace(/%{value}/g, value)

    val = model[field]()
    return if not val and options.allow_nil
    if values.indexOf(val) < 0 then format(options.message || "is not included in the list", val) else null

  exclusion: (model, field, options) ->
    values = options['in'] || options.within
    throw "Please specify the values {in: [1, 2, 5]}" unless values
    format = (msg, value) ->
      msg.replace(/%{value}/g, value)

    val = model[field]()
    if values.indexOf(val) >= 0 then format(options.message || "is reserved", val) else null

  format: (model, field, options) ->
    match = options.with
    wont_match = options.without
    throw "Please specify the with (or without) RegEx {'with': /\d+/}" unless match or wont_match

    val = model[field]()
    valStr = if val then val.toString() else ''
    return if not val and options.allow_nil

    if (match and not valStr.match match) or (wont_match and valStr.match wont_match)
      return options.message or "is invalid"
    return null

  length: (model, field, options) ->
    val = model[field]()
    val = if val then  val.toString().length else 0

    {minimum, maximum} = options
    format = (msg, count, value) ->
      msg.replace(/%{count}/g, count).replace(/%{value}/g, value)

    custom_message = options.messages || {}

    # minimum == maximum
    if (exact = minimum) and minimum == maximum and val != exact
      return format(custom_message.wrong_length || options.message || "should be exactly #{exact} charaters long", exact, val)

    if minimum and val < minimum
      return format(custom_message.too_short || options.message || "should be at least #{minimum} characters long", minimum, val)
    if maximum and val > maximum
      return format(custom_message.too_long || options.message || "should be no longer than #{maximum} characters", maximum, val)

    return null

  custom: (model, field, options) ->
    # Treat options as a mandatory callback
    options.call(model, model)


