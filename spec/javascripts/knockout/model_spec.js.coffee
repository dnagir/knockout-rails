class Page extends ko.Model
  @persistAt 'page'
  @upon 'sayHi', (hi) ->
    @sayHi = hi
 
  @beforeSave ->
    @beforeSaved = true


describe "Model", ->

  beforeEach ->
    jasmine.Ajax.useMock()
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
    it "should return jQuery deferred when saving", ->
      expect( @page.save().done ).toBeTruthy()

    it "should include CSRF token", ->
      @page.save()
      csrf = mostRecentAjaxRequest().requestHeaders['X-CSRF-Token']
      expect(csrf).toBeTruthy()

    it "should be PUT", ->
      @page.save()
      @page.id 123
      method = mostRecentAjaxRequest().method
      expect(method).toBe "PUT"

    it "should be POST", ->
      @page.id null
      @page.save()
      method = mostRecentAjaxRequest().method
      expect(method).toBe "POST"

    it "should include the JSON data", ->
      @page.save()
      sent = mostRecentAjaxRequest().params
      expect(sent).toBe JSON.stringify
        page:
          id: 123
          name: 'Home'
          content: 'Hello'

    it "should not save if invalid", ->
      @page.errors.name 'whatever'
      expect(@page.save()).toBeFalsy()
      expect(mostRecentAjaxRequest()).toBeFalsy()

    describe "errors", ->

      it "should have errors on fields only", ->
        keys = Object.keys(@page.errors)
        expect(keys).toContain 'id'
        expect(keys).toContain 'name'
        expect(keys).toContain 'content'
        expect(keys.length).toBe 3

      it "should have errors for fields", ->
        e = @page.errors
        e.name('a')
        e.content('b')
        e = @page.errors
        expect(e.name()).toBe 'a'
        expect(e.content()).toBe 'b'

      describe "on 200 response", ->
        it "should be valid", ->
          @page.save()
          mostRecentAjaxRequest().response
            status: 200
            responseText: "{}"
          expect( @page.isValid() ).toBeTruthy()
              

      describe "on 422 resposne (unprocessible entity = validation error)", ->
        it "should set errors for returned fields", ->
          @page.save()
          mostRecentAjaxRequest().response
            status: 422
            responseText: '{"name": ["got ya", "really"]}'
          expect( @page.errors.name() ).toBe "got ya, really"

  describe "events", ->
    it "should raise events", ->
      @page.trigger('sayHi', 'abc')
      expect(@page.sayHi).toBe 'abc'

  describe "callbacks", ->
    it "beforeSave should be called ", ->
      @page.save()
      expect(@page.beforeSaved).toBeTruthy()
