
class Page extends ko.Model
  @fields 'name', 'correct', 'multiple'

  @validates: (me) ->
    @presence 'name'
    @presence 'multiple', 'multiple', 'multiple', message: 'xxx'

    @custom 'correct', (page, options) ->
      unless page.correct() then 'should be correct' else null



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

  it "should use custom validator", ->
    @subject.correct yes
    expect( @subject.errors.correct() ).toBeFalsy()
    @subject.correct no
    expect( @subject.errors.correct() ).toMatch /correct/


  it "should join all the errors", ->
    @subject.multiple ''
    expect(@subject.errors.multiple()).toBe "xxx, xxx, xxx"

