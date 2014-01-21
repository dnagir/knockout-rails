class Page extends ko.Model
  @upon 'sayHi', (hi) ->
    @sayHi = hi
 
  @beforeSave ->
    @beforeSaved = true

class CompanyEmployeePage extends ko.Model

class Company extends ko.Model
  @persistAt 'admin/companies' # custom plural form and namespaces
class BadPage extends ko.Model
  @fields 'bank'
  @validates: ->
    @presence 'bank'

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
    @page.id(111)
    @page._destroy = true
    expect(@page.persisted()).toBeFalsy()

  it "should duplicate instance", ->
    page_duplicate = @page.dup()
    expect(page_duplicate).not.toBe @page
    expect(page_duplicate.toJSON()).toEqual @page.toJSON()

  it "should set data from another model", ->
    another = new Page
      id: 300
      name: 'Another'

    @page.set another
    expect(@page).not.toBe another
    expect(@page.toJSON()).toEqual another.toJSON()

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

    # TODO Delete

    it "should persist at model name if url not given", ->
      @page.id(111)
      @page.save()
      expect(mostRecentAjaxRequest().url).toBe "/pages/111"

      cep = new CompanyEmployeePage({id: 111})
      cep.save()
      expect(mostRecentAjaxRequest().url).toBe "/company_employee_pages/111"

    it "should persist at given url", ->
      company = new Company({id: 111})
      company.save()
      expect(mostRecentAjaxRequest().url).toBe "/admin/companies/111"

    it "should include the JSON data", ->
      @page.save()
      sent = mostRecentAjaxRequest().params
      expect(sent).toBe JSON.stringify
        page:
          id: 123
          name: 'Home'
          content: 'Hello'

    it "should not save if invalid", ->
      bad_page = new BadPage
      expect(bad_page.save()).toBeFalsy()
      expect(mostRecentAjaxRequest()).toBeFalsy()

    describe "errors", ->

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
            responseText: '{"errors": {"name": ["got ya", "really"]}}'
          expect( @page.errors.name() ).toBe "got ya, really"

  describe "events", ->
    it "should raise events", ->
      @page.trigger('sayHi', 'abc')
      expect(@page.sayHi).toBe 'abc'

  describe "callbacks", ->
    it "beforeSave should be called ", ->
      @page.save()
      expect(@page.beforeSaved).toBeTruthy()

    #TODO instance callback, jasmine spies

