
class Page extends ko.Model
  @fields 'name', 'correct', 'multiple', 'conditional'

  @validates: (me) ->
    @presence 'name'
    @presence 'multiple', 'multiple', 'multiple', message: 'xxx'

    @custom 'correct', (page, options) ->
      unless page.correct() then 'should be correct' else null


    @presence 'conditional', {only: (-> @only()), except: (-> @except()) }

  only: -> true
  except: -> false

describe "Validations", ->

  beforeEach ->
    @subject = new Page()

  it "should set error on a field", ->
    @subject.name ''
    expect(@subject.errors.name()).toMatch /blank/i

  it "should remove error when field becomes valid", ->
    @subject.name ''
    @subject.name 'myself'
    expect(@subject.errors.name()).toBe null

  it "should use custom validator", ->
    @subject.correct yes
    expect( @subject.errors.correct() ).toBeFalsy()
    @subject.correct no
    expect( @subject.errors.correct() ).toMatch /correct/


  it "should join all the errors", ->
    @subject.multiple ''
    expect(@subject.errors.multiple()).toBe "xxx, xxx, xxx"



  describe "conditional validations", ->

    it "should not validate when ONLY returns false", ->
      @subject.only = -> false
      @subject.conditional ' '
      expect(@subject.errors.conditional()).toBeFalsy()

    it "should validate when ONLY returns true", ->
      @subject.only = -> true
      @subject.conditional ' '
      expect(@subject.errors.conditional()).toBeTruthy()


    it "should not validate when EXCEPT returns true", ->
      @subject.except = -> true
      @subject.conditional ' '
      expect(@subject.errors.conditional()).toBeFalsy()

    it "should validate when EXCEPT returns false", ->
      @subject.except = -> false
      @subject.conditional ' '
      expect(@subject.errors.conditional()).toBeTruthy()

    it "should validate when ONLY=true, EXCEPT=false", ->
      @subject.only = -> true
      @subject.except = -> false
      @subject.conditional ' '
      expect(@subject.errors.conditional()).toBeTruthy()

    it "should not validate when ONLY=true, EXCEPT=true", ->
      @subject.only = -> true
      @subject.except = -> true
      @subject.conditional ' '
      expect(@subject.errors.conditional()).toBeFalsy()

    it "should not validate when ONLY=false, EXCEPT=true", ->
      @subject.only = -> false
      @subject.except = -> true
      @subject.conditional ' '
      expect(@subject.errors.conditional()).toBeFalsy()

    it "should not validate when ONLY=false, EXCEPT=false", ->
      @subject.only = -> false
      @subject.except = -> false
      @subject.conditional ' '
      expect(@subject.errors.conditional()).toBeFalsy()
