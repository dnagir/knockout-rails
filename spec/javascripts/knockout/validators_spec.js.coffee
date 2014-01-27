describe "ko.Validations.validators", ->
  isErrorFor = (validator, val, options={}) ->
    model =
      name: ko.observable(val)
    ko.Validations.validators[validator](model, 'name', options)



  describe "presence", ->
    isError = (val, options={}) -> isErrorFor('presence', val, options)

    it "should not allow all kinds of bllanks", ->
      expect(isError null).toBeTruthy()
      expect(isError undefined).toBeTruthy()
      expect(isError undefined).toBeTruthy()
      expect(isError "").toBeTruthy()
      expect(isError " ").toBeTruthy()
      expect(isError "    ").toBeTruthy()

    it "should allow non-blanks", ->
        expect(isError '123').toBeFalsy()
        expect(isError ' x ').toBeFalsy()
        expect(isError 123).toBeFalsy()

    it "should have default message", ->
      expect(isError '').toBe "can't be blank"

    it "should use custom message", ->
      expect(isError '', message: 'xxx').toBe 'xxx'

  describe "custom", ->
    isError = (fn) -> isErrorFor('custom', 'val', fn)

    it "should return the custom result", ->
      expect(isError -> "hi").toBe "hi"

    it "should accept args", ->
      isError (model) ->
        expect(model.name()).toBe 'val'


  describe "acceptance", ->
    isError = (val, opts={}) -> isErrorFor('acceptance', val, opts)

    it "should not allow falsy", ->
      expect(isError false).toBeTruthy()
      expect(isError null).toBeTruthy()
      expect(isError undefined).toBeTruthy()
      expect(isError '').toBeTruthy()

    it "should allow truthy", ->
      expect(isError true).toBeFalsy()
      expect(isError 123).toBeFalsy()
      expect(isError ' ').toBeFalsy()
      expect(isError 'x').toBeFalsy()



  describe "confirmation", ->
    isError = (val, confirmation) ->
      model =
        pass: ko.observable(val)
        pass_conf: ko.observable(confirmation)
      ko.Validations.validators.confirmation(model, 'pass', confirmedBy: 'pass_conf')

    it "should not allow unconfirmed", ->
      expect(isError 'a', 'b').toBeTruthy()
      expect(isError 'a', '').toBeTruthy()
      expect(isError 'a', null).toBeTruthy()

    it "should allow confirmed", ->
      expect(isError 'a', 'a').toBeFalsy()
      expect(isError '', '').toBeFalsy()
      expect(isError null, null).toBeFalsy()
      expect(isError undefined, null).toBeFalsy()
      expect(isError undefined, '').toBeFalsy()
      expect(isError undefined, 'asd').toBeFalsy()
      expect(isError '', 'asd').toBeFalsy()



  describe "numericality", ->
    isError = (val, opts={}) -> isErrorFor('numericality', val, opts)

    it "should not allow for non-numbers", ->
      expect(isError "asd").toBeTruthy()

    it "should not allow non integers", ->
      expect(isError '123.45', only_integer: true).toBeTruthy()

    it "should allow floats", ->
      expect(isError '123.45').toBeFalsy()
      expect(isError '123.45', greater_than: 123).toBeFalsy()

    it "should allow", ->
      expect(isError "", allow_nil:true).toBeFalsy()
      expect(isError undefined, allow_nil:true).toBeFalsy()
      expect(isError null, allow_nil:true).toBeFalsy()
      expect(isError '123').toBeFalsy()

    it "should respec greater_than option", ->
      expect(isError 123, greater_than: 200).toBeTruthy()
      expect(isError 123, greater_than: 100).toBeFalsy()
      expect(isError -1, greater_than: 0).toBeTruthy()
      expect(isError -1, greater_than: -2).toBeFalsy()

    it "should respec greater_than_equal option", ->
      expect(isError 100, greater_than_equal: 100).toBeFalsy()

    it "should respec odd option", ->
      expect(isError -1, odd: true).toBeFalsy()
      expect(isError 2, odd: true).toBeTruthy()

    it "should respec less_than option", ->
      expect(isError 0, less_than: 0).toBeTruthy()

    it "should respec less_than_equal option", ->
      expect(isError 0, less_than_equal: 0).toBeFalsy()



  describe "inclusion", ->
    isError = (val, values) -> isErrorFor('inclusion', val, in: values, allow_nil:true)

    it "should not allow", ->
      expect(isError 'a', ['b', 'c']).toBeTruthy()

    it "should allow", ->
      expect(isError 'b', ['b', 'c']).toBeFalsy()
      expect(isError '', ['b', 'c']).toBeFalsy()
      expect(isError null, ['b', 'c']).toBeFalsy()



  describe "exclusion", ->
    isError = (val, values) -> isErrorFor('exclusion', val, in: values, allow_nil:true)

    it "should allow", ->
      expect(isError 'a', ['b', 'c']).toBeFalsy()
      expect(isError '', ['b', 'c']).toBeFalsy()
      expect(isError null, ['b', 'c']).toBeFalsy()

    it "should not allow", ->
      expect(isError 'b', ['b', 'c']).toBeTruthy()



  describe "format", ->
    isError = (val, rx) -> isErrorFor('format', val, with: rx, allow_nil:true)

    it "should not allow", ->
      expect(isError 'asd', /\d/).toBeTruthy()
      expect(isError 123, /xxx/).toBeTruthy()

    it "should allow", ->
      expect(isError '', /asd/).toBeFalsy()
      expect(isError null, /asd/).toBeFalsy()
      expect(isError 123, /\d/).toBeFalsy()
      expect(isError 'asd', /asd/).toBeFalsy()


  describe "length", ->
    isError = (val, options) -> isErrorFor('length', val, options)

    it "with min", ->
      expect(isError 'x', minimum: 2).toBeTruthy()
      expect(isError 'x', minimum: 1).toBeFalsy()
      expect(isError 'x', minimum: 0).toBeFalsy()

    it "with max", ->
      expect(isError 'xxx', maximum: 2).toBeTruthy()
      expect(isError 'xxx', maximum: 3).toBeFalsy()
      expect(isError 'xxx', maximum: 4).toBeFalsy()

    it "should allow", ->
      expect(isError null, minimum: 2).toBeFalsy()
      expect(isError undefined, minimum: 2).toBeFalsy()
      expect(isError '', minimum: 2).toBeFalsy()

    it "should have descriptive message", ->
      expect(isError 'xxx', minimum: 11).toBe "should be at least 11 characters long"
      expect(isError 'xxx', maximum: 2).toBe "should be no longer than 2 characters"
      expect(isError 'xxx', minimum: 1, maximum: 2).toBe "should be no longer than 2 characters"
      expect(isError 'xxx', minimum: 5, maximum: 7).toBe "should be at least 5 characters long"


