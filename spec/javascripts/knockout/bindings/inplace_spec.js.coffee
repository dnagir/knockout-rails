#= require knockout/bindings/inplace

describe "In-Place edit", ->

  inplacify = (val) ->
    setFixtures "<input id='el' data-bind='inplace: val' />"
    el = $('#el')
    ko.applyBindings { val: val or ko.observable() }, @el[0]
    el

  it "should hide input initially", ->
    el = inplacify()
    expect(el).toBeHidden()

  it "should show the current value", ->
    val = ko.observable 'hi there'
    el = inplacify val
    expect(el.parent().find '.editable-content').toHaveText 'hi there'

  it "should create an Edit link", ->
    el = inplacify()
    expect(el.parent()).toContain "a.inline-button"

  it "should show input when clicking the Edit link", ->
    el = inplacify()
    el.parent().find('a.inline-button').click()
    expect(el).toBeVisible()

  it "should not update the value on 'change' event", ->
    val = ko.observable 'Initial'
    el = inplacify val
    el.val 'from dom'
    el.change()
    expect(val()).toBe 'Initial'

  it "should update the value clicking Done", ->
    val = ko.observable 'initial'
    el = inplacify val
    el.parent().find('.inline-button').click() # Edit
    el.val('updated')
    el.parent().find('.inline-button').click() # Done
    expect( val() ).toBe 'updated'

  it "should switch from Edit mode when the value has been changed", ->
    val = ko.observable 'hiii'
    el = inplacify val
    button = el.parent().find('.inline-button')
    button.click() # Editing (Done label)
    el.val('bye')
    button.click() # Showing -> (Edit label)
    expect(button).toHaveText('Edit')
    expect(el.parent().find('.editable-content')).toBeVisible()

  it "should switch from Edit mode when nothing has been changed", ->
    val = ko.observable 'hiii'
    el = inplacify val
    button = el.parent().find('.inline-button')
    button.click() # Editing (Done label)
    button.click() # Showing -> (Edit label)
    expect(button).toHaveText('Edit')
    expect(el.parent().find('.editable-content')).toBeVisible()
