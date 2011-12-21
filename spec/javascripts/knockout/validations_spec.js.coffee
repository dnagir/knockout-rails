
class Page extends ko.Model
  @fields 'name'

  @validates: (me) ->
    @presence 'name'



describe "Validations", ->

  beforeEach ->
    @subject = new Page()

  it "should set error on a field", ->
    @subject.name ''
    expect(@subject.errors.name()).toMatch /blank/i

  it "should remove error when field becomes valid", ->
    @subject.name ''
    @subject.name 'myself'
    expect(@subject.errors.name()).toBeFalsy()
