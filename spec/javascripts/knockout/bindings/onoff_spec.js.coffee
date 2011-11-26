#= require knockout/bindings/onoff

describe "iOS Style Checkboxes", ->
  iphonify = ->
    setFixtures "<input id='check' type='checkbox' data-bind='onoff: isVisible' />"
    el = $ '#check'
    ko.applyBindings {isVisible: ko.observable(true)}, el[0]
    el

  it "should convert checkboxe into button", ->
    expect(iphonify().parent()).toBe ".iPhoneCheckContainer"
