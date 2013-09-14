PixelArtCtrl = ($scope) ->

  $scope.actor_definition = null
  $scope.colors = []
  $scope.colors.push("rgba(255,255,255,255)")
  $scope.colors.push("rgba(180,180,180,255)")
  $scope.colors.push("rgba(100,100,100,255)")
  $scope.colors.push("rgba(0,0,0,255)")
  for h in [0..70] by 10
    [r,g,b] = hsvToRgb(h/80.0,1,1)
    $scope.colors.push("rgba(#{Math.round(r)},#{Math.round(g)},#{Math.round(b)},255)")
    [r,g,b] = hsvToRgb(h/80.0,0.4,1)
    $scope.colors.push("rgba(#{Math.round(r)},#{Math.round(g)},#{Math.round(b)},255)")
    [r,g,b] = hsvToRgb(h/80.0,0.4,0.75)
    $scope.colors.push("rgba(#{Math.round(r)},#{Math.round(g)},#{Math.round(b)},255)")
    [r,g,b] = hsvToRgb(h/80.0,1,0.5)
    $scope.colors.push("rgba(#{Math.round(r)},#{Math.round(g)},#{Math.round(b)},255)")

  $scope.colorpicker = $('#cp1').colorpicker()
  $scope.colorpicker.show()
  $scope.colorpicker.on 'changeColor', (ev)->
    c = ev.color.toRGB()
    $scope.set_tool_color("rgba(#{c.r},#{c.g},#{c.b},#{c.a})")


  $scope.$root.$on 'edit_appearance', (msg, args) ->
    $scope.actor_definition = args.actor_definition
    img = $scope.actor_definition.img
    if $scope.canvas
      $scope.canvas.setImage(img)
    else
      $scope.canvas = new PixelArtCanvas(img, $('#pixelArtCanvas')[0], $scope)

    frame = $scope.actor_definition.frameForAppearance(args.identifier)
    $scope.canvas.setDisplayedFrame(frame)
    $('#pixelArtModal').modal({show:true})


  $scope.set_tool_color = (color) ->
    $scope.canvas.toolColor = color
    $scope.colorpicker.data('colorpicker').setValue(color)

  $scope.copy = () ->
    $scope.canvas.copy()

  $scope.paste = () ->
    $scope.canvas.paste()

  $scope.flip = (dir) ->
    $scope.canvas.flip(dir)

  $scope.rotate = (deg) ->
    $scope.canvas.rotate(deg)

  $scope.set_tool = (tool) ->
    $scope.canvas.tool.reset()
    $scope.canvas.tool = tool

  $scope.css_for_tool = (tool) ->
    return 'btn-info btn tool icon' if $scope.canvas.tool == tool
    'btn tool icon'

  $scope.close_editor = () ->
    $scope.canvas.cleanup()

  $scope.save_editor = () ->
    return unless $scope.actor_definition
    $scope.canvas.cleanup()
    $scope.actor_definition.updateImageData($scope.canvas.dataURLRepresentation())
    $scope.actor_definition.save()


  $scope.move_editor_to_tile = (x,y) ->
    saveChanges = confirm("Do you want to save your changes to this frame?")
    $scope.canvas.setDisplayedTile(x, y, saveChanges)


window.PixelArtCtrl = PixelArtCtrl