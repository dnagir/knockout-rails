describe "Model", ->
  it "comming soon"

  it "should create observable attributes"
  it "should set an id"
  it "should determine if record is persisted or not"

  describe "Ajax", ->

    it "should include CSRF token"
    it "should be PUT"
    it "should be POST"
    it "should include the JSON data"

    describe "errors", ->
      describe "on 200 response", ->
        it "should clear all errors"

      describe "on 422 resposne", ->
        it "should set errors for returned fields"


