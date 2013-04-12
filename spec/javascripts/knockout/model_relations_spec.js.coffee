describe "Relations", ->

  class Paragraph extends ko.Model
    @persistAt 'paragraph'
    @fields 'content'

  class Page extends ko.Model
    @persistAt 'page'

    @fields 'name'
    # TODO add autosave
    @has_one 'footer', -> Footer # deferred reference to class symbol, because it's defined below Page
    @has_many 'paragraphs', Paragraph

  class Link extends ko.Model
    @persistAt 'link'
    @fields 'url'

  class Footer extends ko.Model
    @persistAt 'footer'

    @fields 'content'
    @belongs_to 'page', Page
    @has_and_belongs_to_many 'links', Link

  beforeEach ->
    jasmine.Ajax.useMock()
    @page = new Page
      name: 'Home'

    @footer = new Footer
      content: 'Footer text'

  it "should create observable attributes", ->
    expect(@page.name).toBeObservable()
    expect(@page.footer).toBeObservable() # has_one
    expect(@page.paragraphs).toBeObservableArray() # has_many
    expect(@footer.page).toBeObservable() # belongs_to
    expect(@footer.links).toBeObservableArray() # has_and_belongs_to_many

  it "should have default values set", ->
    expect(@page.footer()).toBeNull # has_one
    expect(@page.paragraphs()).toEqual [] # has_many
    expect(@footer.page()).toBeNull # belongs_to
    expect(@footer.links()).toEqual [] # has_and_belongs_to_many

  it "should create instance of specified model", ->
    page = new Page
      footer:
        content: 'Footer text'
      paragraphs: [
        {content: 'Para 1'}
        {content: 'Para 2'}
      ]

    footer = new Footer
      page:
        name: 'Home'
      links: [
        {url: 'url1'}
        {url: 'url2'}
      ]

    expect(page.footer()).toBeInstanceOf 'Footer'
    expect(page.paragraphs()[0]).toBeInstanceOf 'Paragraph'
    expect(footer.page()).toBeInstanceOf 'Page'
    expect(footer.links()[0]).toBeInstanceOf 'Link'

  it "should have sent nested models - has_one", ->
    @page.footer @footer

    @page.save()
    sent = mostRecentAjaxRequest().params
    expect(sent).toBe JSON.stringify
                        page:
                          name: 'Home'
                          footer_attributes: {
                            id: undefined
                            content: 'Footer text'
                            links_attributes: []
                          }
                          paragraphs_attributes: []


  it "should have sent nested models - belongs_to", ->
    @footer.page @page

    @footer.save()
    sent = mostRecentAjaxRequest().params
    expect(sent).toBe JSON.stringify
                        footer:
                          content: 'Footer text'
                          page_attributes: {
                            id: undefined
                            name: 'Home'
                            paragraphs_attributes: []
                          }
                          links_attributes: []

  it "should have sent nested models - has_many", ->
    @page.paragraphs.push new Paragraph({content: 'Para 1'})
    @page.paragraphs.push new Paragraph({content: 'Para 2'})

    @page.save()
    sent = mostRecentAjaxRequest().params
    expect(sent).toBe JSON.stringify
                        page:
                          name: 'Home'
                          paragraphs_attributes: [{
                            id: undefined
                            content: 'Para 1'}, {
                            id: undefined
                            content: 'Para 2'
                          }]










