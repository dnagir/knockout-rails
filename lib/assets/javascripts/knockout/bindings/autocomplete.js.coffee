#= require pakunok/jquery-ui/pack/autocomplete

$ = jQuery

getFieldKey = (obj, label) ->
  key = [label, 'name', 'label', 'value'].find (key) -> obj[key]?

getLabel = (obj, label) ->
  key = getFieldKey obj, label
  return obj unless key
  ko.utils.unwrapObservable obj[key]


getTerm = (obj, label) ->
  item = obj.item or obj
  key = getFieldKey item, label
  return item unless key

  value = ko.utils.unwrapObservable item[key]
  value or item


filter = (source, term, label) ->
  matcher = new RegExp( $.ui.autocomplete.escapeRegex(term), "i" )
  source.filter (obj) -> matcher.test getTerm(obj, label)


ko.bindingHandlers.autocomplete =
  init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
    binding = valueAccessor()

    options =
      delay: binding.delay
      minLength: binding.minLength

    options.select = (e, ui) ->
      debugger
      binding.select(ui.item.item) if binding.select

    options.source = (request, response) ->
      src = ko.utils.unwrapObservable binding.source
      if src['fail']? and src['done']? and src['always']
        # Looks like it's a jQuery.Deferred
        src.done (data) -> response filter(data, request.term, binding.label)
        src.fail -> response []
      else
        response filter(src, request.term, binding.label)


    options.minLength = 2 unless options.minLength?

    ac = $(element).autocomplete(options).data 'autocomplete'
    ac._normalize = (items) ->
      items.map (it) ->
        label: getLabel(it, binding.label)
        value: getTerm(it, binding.label)
        item: it # This gives acces to the actual object

    ac._renderItem = (ul, item) ->
      txt = getTerm item, binding.label
      $( "<li></li>" )
        .data("item.autocomplete", item)
        .append( $("<a></a>").text txt )
        .appendTo(ul)


