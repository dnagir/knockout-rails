#= require knockout/bindings/color

describe "Color picker", ->
  colorise = (color)->
    setFixtures "<div id='color' data-bind='color: color' />"
    el = $ '#color'
    ko.applyBindings {color: color or ko.observable("rgb(1, 2, 3)")}, el[0]
    el

  afterEach ->
    # It adds itself to the body, so is outisde of the fixure
    $(".colorpicker").remove()

  it "should set the initial background color", ->
    el = colorise()
    expect(el.css 'backgroundColor').toBe 'rgb(1, 2, 3)'

  it "should add 'color' class to element", ->
    el = colorise()
    expect(el).toBe ".color"


  it "should reflect the changed color in the UI", ->
    color = ko.observable "rgb(1, 2, 3)"
    el = colorise color
    color "rgb(4, 5, 6)" # Modify the color here
    expect(el.css 'backgroundColor').toBe 'rgb(4, 5, 6)'
    

  it "should update the value when user changes the color", ->
    color = ko.observable "rgb(1, 2, 3)"
    el = colorise color
    $(".colorpicker").data('colorpicker').onChange "hsb", "hex", {r: 4, g: 5, b: 6}
    expect(color()).toBe 'rgb(4, 5, 6)'

