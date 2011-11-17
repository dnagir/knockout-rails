class Page extends ko.Model
 @configure 'page'


describe "Model", ->

  beforeEach ->
    @page = new Page
      id: 123
      name: 'Home'
      content: 'Hello'


  it "should create observable attributes", ->
    expect(@page.name()).toBe 'Home'
    expect(@page.content()).toBe 'Hello'

  it "should set an id", -> expect(@page.id()).toBe 123

  it "should determine if record is persisted or not", ->
    @page.id(111)
    expect(@page.persisted()).toBeTruthy()
    @page.id(null)
    expect(@page.persisted()).toBeFalsy()

  describe "Ajax", ->

    it "should include CSRF token"
    it "should be PUT"
    it "should be POST"
    it "should include the JSON data"

    describe "errors", ->
      describe "on 200 response", ->
        it "should clear all errors"

      describe "on 422 resposne", ->
        it "should set errors for returned fields"


