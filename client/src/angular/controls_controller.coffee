
ControlsCtrl = ($scope) ->

  window.controlsScope = $scope

  $scope.set_running = (r) ->
    window.Game.running = r

  $scope.step = () ->
    window.Game.update(true)

  $scope.step_back = () ->
    window.Game.frameRewind()

  $scope.reset = () ->

  $scope.speed = () ->
    return 0 unless window.Game
    window.Game.simulationFrameRate

  $scope.set_speed = (speed) ->
    window.Game.simulationFrameRate = speed

  $scope.running = () ->
    return false unless window.Game
    window.Game.running

  $scope.class_for_btn = (istrue) ->
    if istrue then 'btn btn-info' else 'btn'


window.ControlsCtrl = ControlsCtrl