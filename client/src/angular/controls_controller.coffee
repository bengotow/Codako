
ControlsCtrl = ($scope) ->

  window.controlsScope = $scope

  $scope.control_set = 'testing'

  $scope.$root.$on 'start_compose_rule', (msg, args) ->
    $scope.control_set = 'record-preflight'

  $scope.$root.$on 'set_tool', (msg, args) ->
    $scope.$apply() unless $scope.$$phase

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

  $scope.tool = () ->
    window.Game?.tool

  $scope.set_tool = (t) ->
    window.Game.setTool(t)

  $scope.definition_name = () ->
    return undefined unless window.Game && window.Game.selectedDefinition
    window.Game.selectedDefinition.name

  # -- Recording Controls -- #

  $scope.start_recording = () ->
    window.Game.focusAndStartRecording()
    $scope.control_set = 'recording'

  $scope.cancel_recording = () ->
    window.Game.exitRecordingMode()
    $scope.control_set = 'testing'

  $scope.save_recording = () ->
    window.Game.saveRecording()
    $scope.control_set = 'testing'

  $scope.recording_checks = () ->
    window.Game.recordingChecks

  $scope.save_recording_check_value = (id) ->

  $scope.ondrop = (event, ui) ->
    variableID = ui.draggable.data('identifier')
    variable = window.Game.selectedDefinition.variables()[variableID]
    variableValue = window.Game.selectedActor.variableValue(variableID)

    checkID = $(event.target).data('identifier')
    window.Game.recordingCheck(checkID)['_id'] = variableID
    if window.Game.recordingChecks[-1]._id == checkID
      window.Game.addRecordingCheck()

    debugger



window.ControlsCtrl = ControlsCtrl