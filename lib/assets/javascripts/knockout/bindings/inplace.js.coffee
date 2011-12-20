showInput = (element, showOrHide, valueAccessor) ->
  el = $(element)
  editable = el.next()
  button = editable.next()
  editable.toggle(!showOrHide)
  el.toggle(showOrHide)
  val = ko.utils.unwrapObservable valueAccessor()
  if showOrHide
    button.text 'Done'
    el.val val
  else
    button.text 'Edit'
    editable.text val


toggle = (element, valueAccessor) ->
  showingInput = not editing(element)
  showInput element, showingInput, valueAccessor

updateValue = (element, valueAccessor) ->
  valueAccessor()( $(element).val() )

editing = (element) -> $(element).is(':visible')

ko.bindingHandlers.inplace =
  init: (element, valueAccessor) ->
    val = ko.utils.unwrapObservable valueAccessor()
    editable = $("<span class='editable-content' />").insertAfter(element)
    button = $("<a href='#' class='inline-button'>Edit</a>").insertAfter editable
    showInput element, false, valueAccessor

    button.closest('form').submit ->
      updateValue element, valueAccessor if editing(element)
      showInput element, false, valueAccessor
    button.click (e) ->
      e.preventDefault()
      if editing element
        updateValue element, valueAccessor
        showInput element, false, valueAccessor
      else
        toggle element, valueAccessor


  update: (element, valueAccessor) ->
    showInput element, false, valueAccessor
