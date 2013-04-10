class Page extends ko.Model
  @persistAt 'page'
  # no fields specified - pass all observables
  @

class Pagee extends ko.Model
  @persistAt 'pagee'
  # no fields specified - pass all observables
  @


class Todo extends ko.Model
  @persistAt 'todo'
  @fields 'what', 'priority' # fields specified, pass just them
  @

describe "Mapping Model", ->

  beforeEach ->
    @page = new Page
      id: 123
      name: 'Home'
      content: 'Hello'

    @empty_page = new Page()

    # Changed order of initialization
    @empty_pagee = new Pagee()
    @pagee = new Pagee
      id: 123
      name: 'Home'
      content: 'Hello'

    @todo = new Todo
      what: 'Milk'
      priority: 10
      weird_property: 'What I am doing here?'

    @empty_todo = new Todo

  it "should create observable attributes for fields always", ->
    #expect(@todo.what).toEqual jasmine.any(Function) # observable
    expect(@todo.what).toBeObservable()
    expect(@empty_todo.what).toEqual jasmine.any(Function) # observable

    expect(@todo.what()).toBe 'Milk'
    expect(@empty_todo.what()).toBeUndefined()

  it "should create observables only for given attributes if fields not specified", ->
    expect(@page.name).toBeObservable()
    expect(@pagee.name).toBeObservable()
    expect(@empty_page.name).toBeUndefined()
    expect(@empty_pagee.name).toBeUndefined()

    expect(@page.name()).toBe 'Home'

  it "should allow to extend models without given fields", ->
    expect(@empty_page.name).toBeUndefined() # name function not defined
    expect(@empty_pagee.name).toBeUndefined() # name function not defined

    @empty_page.name = ko.observable('Login')
    expect(@empty_page.name()).toBe 'Login'
    expect(@empty_page.toJSON()).toEqual {name: 'Login'} # and it serializes it right

  it "should not allow to extend models if fields given", ->
    @empty_todo.name = ko.observable('Named Todo')
    expect(@empty_todo.toJSON()).toEqual {id: undefined}

  it "should serialize what was given wihout given fields", ->
    expect(@page.toJSON()).toEqual {id: 123, name: 'Home', content: 'Hello'}
    expect(@empty_page.toJSON()).toEqual {id: undefined}

  it "should serialize only fields if given", ->
    expect(@todo.toJSON()).toEqual {what: 'Milk', priority: 10, id: undefined}

