PixelArtCtrl = ($scope) ->

  $scope.actor_definition = null

  $scope.colors = ['rgba(255, 0, 0, 255)',
                   'rgba(255, 100, 100, 255)',
                   'rgba(100, 0, 0, 255)',
                   'rgba(0, 0, 0, 255)',
                   'rgba(100, 100, 100, 255)',
                   'rgba(255, 255, 255, 255)',
                   'rgba(0, 255, 0, 255)',
                   'rgba(100, 255, 100, 255)',
                   'rgba(0, 100, 0, 255)',
                   'rgba(0, 0, 255, 255)',
                   'rgba(100, 100, 255, 255)',
                   'rgba(0, 0, 100, 255)']

  $scope.colorpicker = $('#cp1').colorpicker()
  $scope.colorpicker.show()
  $scope.colorpicker.on 'changeColor', (ev)->
    $scope.set_active_color(ev.color.toRGB())


  $scope.$root.$on 'edit_animation', (msg, args) ->
    $scope.actor_definition = args.actor_definition
    img = $scope.actor_definition.img
    if $scope.canvas
      $scope.canvas.setImage(img)
    else
      $scope.canvas = new PixelArtCanvas(img, $('#pixelArtCanvas')[0], $scope)
    $scope.canvas.setDisplayedTile(args.coords[0], args.coords[1])
    $('#pixelArtModal').modal({show:true})


  $scope.set_tool_color = (color) ->
    $scope.canvas.toolColor = color


  $scope.set_tool = (tool) ->
    $scope.canvas.tool = tool


  $scope.save_editor = () ->
    return unless $scope.actor_definition
    $scope.actor_definition.updateImageData($scope.canvas.dataURLRepresentation())
    $scope.actor_definition.save()


  $scope.move_editor_to_tile = (x,y) ->
    saveChanges = confirm("Do you want to save your changes to this frame?")
    $scope.canvas.setDisplayedTile(x, y, saveChanges)


window.PixelArtCtrl = PixelArtCtrl