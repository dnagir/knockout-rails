#= require knockout/bindings/animate

describe "Animate binding", ->
  beforeEach ->
    @animate = spyOn jQuery.fn, 'animate'
    binding = "width: dataUsed, height: dataUsed(), duration: 2000, easing: 'linear', complete: flash"
    setFixtures "<div id='anim' data-bind=\"animate: {#{binding}}\" /> "
    @el = $("#anim")
    @targetSize = 600
    ko.applyBindings {
      dataUsed: ko.observable(@targetSize),
      flash: ->{}
    }, @el[0]

  it "should call the jQuery animate", ->
    expect(@animate).toHaveBeenCalled()

  it "should have correct css properties to animate", ->
    properties = @animate.mostRecentCall.args[0]
    expect(properties.width).toBe @targetSize
    expect(properties.height).toBe @targetSize

  it "should have correct animation options", ->
    options = @animate.mostRecentCall.args[1]
    expect(options.duration).toBe 2000
    expect(options.easing).toBe 'linear'
    expect(typeof options.complete).toBe 'function'

