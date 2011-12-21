
class Page extends ko.Model
  @fields 'name', 'correct'

  @validates: (me) ->
    @presence 'name'
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
