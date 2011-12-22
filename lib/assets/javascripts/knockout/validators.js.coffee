#= require knockout/validations

ko.Validations.validators =
  acceptance: (model, field, options) ->
    val = model[field]()
    unless val then options.message || "needs to be accepted" else null

  presence: (model, field, options) ->
    val = model[field]()
    isBlank = !val or val.toString().isBlank()
    if isBlank then options.message || "can't be blank" else null


  email: (model, field, options) ->
    val = model[field]()
    isValid = !val or val.toString().match /.+@.+\..+/
    unless isValid then options.message or "should be a valid email" else null


  confirmation: (model, field, options) ->
    otherField = options.confirms
    throw "Please specify which field to apply the confirmation to using {confirms: 'otherField'}" unless otherField
    orig = model[field]()
    other = model[otherField]()
    if orig != other and orig then options.message or "should confirm #{otherField}" else null


  numericality: (model, field, options) ->
    val = model[field]()
    return unless val
    looksLikeNumeric = val.toString().match /^-?\d+$/ # We should do better than this
    num = parseInt val, 10
    min = if options.min? then options.min else num
    max = if options.max? then options.max else num
    if looksLikeNumeric and min <= num <= max then null else options.message or "should be numeric"


  inclusion: (model, field, options) ->
    values = options.values
    throw "Please specify the values {values: [1, 2, 5]}" unless values
    val = model[field]()
    return unless val
    if values.indexOf(val) < 0 then options.message or "should be one of #{values.join(', ')}" else null


  exclusion: (model, field, options) ->
    values = options.values
    throw "Please specify the values {values: [1, 2, 5]}" unless values
    val = model[field]()
    return unless val
    if values.indexOf(val) >= 0 then options.message or "should not be any of #{values.join(', ')}" else null

  format: (model, field, options) ->
    matcher = options.match
    throw "Please specify the match RegEx {match: /\d+/}" unless matcher
    val = model[field]()
    return unless val
    if val.toString().match matcher then null else options.message or "should be formatted properly"

  length: (model, field, options) ->
    val = model[field]()
    return unless val
    val = val.toString().length
    {min, max} = options
    min = val unless min?
    max = val unless max?
    createMsg = ->
      minMsg = if options.min?
        "at least #{min} characters long"
      else
        ""
      maxMsg = if options.max?
        "no longer than #{max} characters"
      else
        ""
      separator = if minMsg and maxMsg then " but " else ""
      "should be #{minMsg}#{separator}#{maxMsg}"
    if min <= val <= max then null else options.message or createMsg()

  custom: (model, field, options) ->
    # Treat options as a mandatory callback
    options.call(model, model)


