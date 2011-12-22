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



  describe "email", ->
    isError = (val, options={}) -> isErrorFor('email', val, options)

    it "shold allow blanks", ->
      expect(isError null).toBeFalsy()
      expect(isError undefined).toBeFalsy()
      expect(isError '').toBeFalsy()

    it "shold not allow non email-ish values", ->
      expect(isError ' ').toBeTruthy()
      expect(isError 123).toBeTruthy()
      expect(isError "xyz").toBeTruthy()
      expect(isError "abc.com").toBeTruthy()
      expect(isError "@").toBeTruthy()
      expect(isError "a@b").toBeTruthy()

    it "should allow email-ish values", ->
        expect(isError 'a@b.c').toBeFalsy()
        expect(isError 'a.b@c.d').toBeFalsy()

    it "should have default message", ->
      expect(isError "xx").toBe "should be a valid email"

    it "should use custom message", ->
      expect(isError 'xx', message: 'xxx').toBe 'xxx'



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
        name: ko.observable(val)
        other: ko.observable(confirmation)
      ko.Validations.validators.confirmation(model, 'name', confirms: 'other')

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

    it "should not allow some numbers", ->
      expect(isError '123.45').toBeTruthy()

    it "should allow", ->
      expect(isError "").toBeFalsy()
      expect(isError undefined).toBeFalsy()
      expect(isError null).toBeFalsy()
      expect(isError '123').toBeFalsy()

    it "should respec min option", ->
      expect(isError 123, min: 200).toBeTruthy()
      expect(isError 123, min: 100).toBeFalsy()
      expect(isError 100, min: 100).toBeFalsy()

      expect(isError -1, min: 0).toBeTruthy()
      expect(isError -1, min: -2).toBeFalsy()
      expect(isError 0, min: 0).toBeFalsy()



  describe "inclusion", ->
    isError = (val, values) -> isErrorFor('inclusion', val, values: values)

    it "should not allow", ->
      expect(isError 'a', ['b', 'c']).toBeTruthy()

    it "should allow", ->
      expect(isError 'b', ['b', 'c']).toBeFalsy()
      expect(isError '', ['b', 'c']).toBeFalsy()
      expect(isError null, ['b', 'c']).toBeFalsy()



  describe "exclusion", ->
    isError = (val, values) -> isErrorFor('exclusion', val, values: values)

    it "should allow", ->
      expect(isError 'a', ['b', 'c']).toBeFalsy()
      expect(isError '', ['b', 'c']).toBeFalsy()
      expect(isError null, ['b', 'c']).toBeFalsy()

    it "should not allow", ->
      expect(isError 'b', ['b', 'c']).toBeTruthy()



  describe "format", ->
    isError = (val, rx) -> isErrorFor('format', val, match: rx)

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
      expect(isError 'x', min: 2).toBeTruthy()
      expect(isError 'x', min: 1).toBeFalsy()
      expect(isError 'x', min: 0).toBeFalsy()

    it "with max", ->
      expect(isError 'xxx', max: 2).toBeTruthy()
      expect(isError 'xxx', max: 3).toBeFalsy()
      expect(isError 'xxx', max: 4).toBeFalsy()

    it "should allow", ->
      expect(isError null, min: 2).toBeFalsy()
      expect(isError undefined, min: 2).toBeFalsy()
      expect(isError '', min: 2).toBeFalsy()

    it "should have descriptive message", ->
      expect(isError 'xxx', min: 11).toBe "should be at least 11 characters long"
      expect(isError 'xxx', max: 2).toBe "should be no longer than 2 characters"
      expect(isError 'xxx', min: 1, max: 2).toBe "should be at least 1 characters long but no longer than 2 characters"

