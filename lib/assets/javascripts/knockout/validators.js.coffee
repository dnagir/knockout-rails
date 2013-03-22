#= require knockout/validations

ko.Validations.validators =
  acceptance: (model, field, options) ->
    # TODO this should add virtual attribute to fields
    val = model[field]()

    return null if not val and options.allow_nil in [true, undefined] # allow_nil defaults to true

    accepted = if options.accept then val == options.accept else val
    unless accepted then options.message || "must be accepted" else null

  presence: (model, field, options) ->
    # TODO i18n zobaczyć w railsach jaki walidator jakie pola obsługuje
    val = model[field]()
    isBlank = !val or val.toString().isBlank()
    if isBlank then options.message || "can't be blank" else null

  email: (model, field, options) ->
    val = model[field]()
    isValid = !val or val.toString().match /.+@.+\..+/
    unless isValid then options.message or "should be a valid email" else null

  confirmation: (model, field, options) ->
    # TODO should add virtual attribute to fields
    confirmationField = options.confirmedBy || field + '_confirmation'
    orig = model[field]()
    confirmation = model[confirmationField]()
    if confirmation and orig != confirmation then options.message or "doesn’t match confirmation" else null

  numericality: (model, field, options) ->
    val = model[field]()
    return unless val
    looksLikeNumeric = val.toString().match /^-?\d+$/ # We should do better than this
    num = parseInt val, 10
    min = if options.min? then options.min else num
    max = if options.max? then options.max else num
    if looksLikeNumeric and min <= num <= max then null else options.message or "should be numeric"

  inclusion: (model, field, options) ->
    values = options['in'] || options.within
    throw "Please specify the values {in: [1, 2, 5]}" unless values
    format = (msg, value) ->
      msg.replace(/%{value}/g, value)

    val = model[field]()
    return null if not val and options.allow_nil
    if values.indexOf(val) < 0 then format(options.message || "is not included in the list", val) else null

  exclusion: (model, field, options) ->
    values = options['in'] || options.within
    throw "Please specify the values {in: [1, 2, 5]}" unless values
    format = (msg, value) ->
      msg.replace(/%{value}/g, value)

    val = model[field]()
    if values.indexOf(val) >= 0 then format(options.message || "is reserved", val) else null

  format: (model, field, options) ->
    matcher = options.match
    throw "Please specify the match RegEx {match: /\d+/}" unless matcher
    val = model[field]()
    return unless val
    if val.toString().match matcher then null else options.message or "should be formatted properly"

  length: (model, field, options) ->
    val = model[field]()
    val = if val then  val.toString().length else 0

    {minimum, maximum} = options
    format = (msg, count, value) ->
      msg.replace(/%{count}/g, count).replace(/%{value}/g, value)

    # minimum == maximum
    if (exact = minimum) and minimum == maximum and val != exact
      return format(options.wrong_length || options.message || "should be exactly #{exact} charaters long", exact, val)

    if minimum and val < minimum
      return format(options.too_short || options.message || "should be at least #{minimum} characters long", minimum, val)
    if maximum and val > maximum
      return format(options.too_long || options.message || "should be no longer than #{maximum} characters", maximum, val)

    return null

  custom: (model, field, options) ->
    # Treat options as a mandatory callback
    options.call(model, model)


