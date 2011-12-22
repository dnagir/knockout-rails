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

