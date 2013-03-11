PixelArtCtrl = ($scope) ->

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

  $scope.set_tool_color = (color) ->
    $scope.canvas.toolColor = color

  $scope.set_tool = (tool) ->
    $scope.canvas.tool = tool

  $scope.open_editor = () ->
    img = window.Game.Content.imageNamed('Player')
    $scope.canvas = new PixelArtCanvas(img, $('#pixelArtCanvas')[0], $scope)


window.PixelArtCtrl = PixelArtCtrl