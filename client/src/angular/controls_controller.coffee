
ControlsCtrl = ($scope) ->

  window.controlsScope = $scope
  $scope.control_set = 'testing'

  $scope.$root.$on 'compose_rule', (msg, args) ->
    $scope.control_set = 'record-preflight'

  # -- Testing Controls -- #

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


  # -- Recording Controls -- #

  $scope.start_recording = () ->
    window.Game.focusAndStartRecording()
    $scope.control_set = 'recording'

  $scope.cancel_recording = () ->
    window.Game.exitRecordingMode()

  $scope.save_recording = () ->
    window.Game.saveRecording()


window.ControlsCtrl = ControlsCtrl