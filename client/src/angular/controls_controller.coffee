
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
    window.Game?.recordingRule?.checks

  $scope.recording_actions = () ->
    window.Game?.recordingRule?.actions

  $scope.icon_for_referenced_actor = (ref, appearance_id = null) ->
    descriptor = window.Game?.recordingRule?.descriptors[ref]
    appearance_id ||= descriptor.appearance
    definition = window.Game.library.definitions[descriptor.identifier]
    definition.iconForAppearance(appearance_id, 26, 26)

  $scope.icon_for_move = (delta) ->
    size = 10
    [x,y] = delta.split(',')
    w = Math.abs(x) + 1
    h = Math.abs(y) + 1

    window.withTempCanvas w * size, h * size, (canvas, context) ->
      context.fillStyle = 'rgba(255,255,255,1)'
      context.fillRect(0,0, w * size, h * size)
      context.beginPath()
      context.strokeStyle = 'rgba(0,0,0,0.3)'
      for xx in [0..w]
        context.moveTo(xx * size, 0)
        context.lineTo(xx * size, h * size)
      for yy in [0..h]
        context.moveTo(0, yy * size)
        context.lineTo(w * size, yy * size)
      context.stroke()

      before = {x:0,y:0}
      after = {x:x/1, y:y/1}
      translate = {x:0, y:0}
      translate.x = -after.x if after.x < 0
      translate.y = -after.y if after.y < 0

      context.fillStyle = 'rgba(150,150,150,1)'
      context.fillRect((before.x + translate.x) * size, (before.y + translate.y) * size, size, size);
      context.fillStyle = 'rgba(255,0,0,1)'
      context.fillRect((after.x + translate.x) * size, (after.y + translate.y) * size, size, size);

      return canvas.toDataURL()

  $scope.name_for_referenced_actor = (ref) ->
    descriptor = window.Game?.recordingRule?.descriptors[ref]
    definition = window.Game.library.definitions[descriptor.identifier]
    definition.name

  $scope.name_for_appearance = (id) ->
    for key,definition of window.Game.library.definitions
      if definition.hasAppearance(id)
        return definition.nameForAppearance(id)
    return "Unknown"

  $scope.name_for_variable = (id) ->
    for key,definition of window.Game.library.definitions
      entry = definition.variables()[id]
      continue unless entry
      return entry.name

  $scope.save_recording_check_value = (id) ->

  $scope.ondrop = (event, ui) ->
    variableID = ui.draggable.data('identifier')
    return unless variableID[0..8] == 'variable:'

    variableID = variableID[9..-1]
    variable = window.Game.selectedDefinition.variables()[variableID]
    variableValue = window.Game.selectedActor.variableValue(variableID)

    checkID = $(event.target).data('identifier')
    window.Game.recordingCheck(checkID)['_id'] = variableID
    if window.Game.recordingChecks[-1]._id == checkID
      window.Game.addRecordingCheck()


  $scope._withTempCanvas = (w, h, func) ->
    canvas = document.createElement("canvas")
    canvas.width = w
    canvas.height = h
    document.body.appendChild(canvas)
    ret = func(canvas)
    document.body.removeChild(canvas)
    ret

window.ControlsCtrl = ControlsCtrl