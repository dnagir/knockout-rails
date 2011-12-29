#= require knockout/bindings/autocomplete

describe "autocomplete", ->

  prepare = (source, label='') ->
    current = ko.observable 'nothing selected'
    setFixtures """
      <input
        id="ac"
        data-bind="autocomplete: {source: source, select: current, label: '#{label}', delay: 0, minLength: 0}"
      />
    """
    data = {source: source, current: current}
    ko.applyBindings data, $("#ac")[0]
    data


  search = (what) -> $("#ac").autocomplete 'search', what
  menu = -> $(".ui-autocomplete.ui-menu")
  itemsText = -> menu().find('li a').map( -> $(@).text() ).toArray().join ','
  select = (label) ->
    item = menu().children('li').filter(-> $(@).text() == label).first()
    menu().data('menu').activate $.Event('click'), item
    item.children().click()



  it "should show menu from array", ->
    prepare ['1', '22', '222', '3']
    search '2'
    expect( itemsText() ).toBe '22,222'
    
  it "should select an observable", ->
    data = prepare ['22']
    search '2'
    select '22'
    expect( data.current() ).toBe '22'

  it "should show names for objects", ->
    prepare [{name: '11', id: 1}, {name: '22', id: 2}], 'name'
    search '1'
    expect( itemsText() ).toBe '11'

  it "should show labels for observable returning jQuery deferred", ->
    prepare d = jQuery.Deferred()
    search '1'
    d.resolve ['11', '22']
    expect( itemsText() ).toBe '11'


  it "should show names for observable objects", ->
    prepare [
      {name: ko.observable('11'), id: 1}
      {name: ko.observable('22'), id: 2}],
      'name'
    search '1'
    expect( itemsText() ).toBe '11'

  it "should select object when source is array of objects", ->
    obj = {name: '22'}
    data = prepare [{name: '11'}, obj], 'name'
    search '2'
    select '22'
    expect( data.current() ).toBe obj
