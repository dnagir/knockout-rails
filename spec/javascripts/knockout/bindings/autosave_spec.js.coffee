#= require knockout/bindings/autosave

class Page extends ko.Model
  @persistAt 'page'

describe "AutoSave", ->
  beforeEach ->
    jasmine.Ajax.useMock()
    jasmine.Clock.useMock()

  prepare = (bindings, viewModel) ->
    page = new Page { name: 'Home' }
    setFixtures "<form id='autosave' data-bind='autosave: #{bindings}' />"
    form = $("#autosave")[0]
    viewModel = if viewModel
        ko.utils.extend viewModel, {page: page}
      else
        {page: page}
    ko.applyBindings viewModel, form
    page



  it "should call 'save' when property changes and use delay", ->
    model = prepare "page"

    model.name 'Index'
    jasmine.Clock.tick 100
    expect(mostRecentAjaxRequest()).toBeFalsy()

    jasmine.Clock.tick 5000
    expect(mostRecentAjaxRequest()).toBeTruthy()


  it "should not save when 'when' condition is falsy", ->
    model = prepare "{model: page, when: shouldSave}", {shouldSave: false}

    model.name 'Index'
    jasmine.Clock.tick 5000
    expect(mostRecentAjaxRequest()).toBeFalsy()

  it "should save when 'when' condition is truthy", ->
    model = prepare "{model: page, when: shouldSave}", shouldSave: ko.observable(true)
    model.name 'Index'
    jasmine.Clock.tick 5000
    expect(mostRecentAjaxRequest()).toBeTruthy()

  it "should save when 'unless' condition is falsy", ->
    model = prepare "{model: page, unless: dontSave}", dontSave: false
    model.name 'Index'
    jasmine.Clock.tick 5000
    expect(mostRecentAjaxRequest()).toBeTruthy()

  it "should not save when 'unless' condition is truthy", ->
    model = prepare "{model: page, unless: dontSave}", dontSave: true
    model.name 'Index'
    jasmine.Clock.tick 5000
    expect(mostRecentAjaxRequest()).toBeFalsy()

  it "should save with when=true, unless=false", ->
    model = prepare "{model: page, when: shouldSave, unless: dontSave}", shouldSave: true, dontSave: false
    model.name 'Index'
    jasmine.Clock.tick 5000
    expect(mostRecentAjaxRequest()).toBeTruthy()

  it "should not save with when=false, unless=false", ->
    model = prepare "{model: page, when: shouldSave, unless: dontSave}", shouldSave: false, dontSave: false
    model.name 'Index'
    jasmine.Clock.tick 5000
    expect(mostRecentAjaxRequest()).toBeFalsy()


  it "should not save with when=true, unless=true", ->
    model = prepare "{model: page, when: shouldSave, unless: dontSave}", shouldSave: true, dontSave: true
    model.name 'Index'
    jasmine.Clock.tick 5000
    expect(mostRecentAjaxRequest()).toBeFalsy()

