
ControlsCtrl = ($scope) ->

  window.controlsScope = $scope

  $scope.control_set = 'testing'

  $scope.$root.$on 'start_compose_rule', (msg, args) ->
    $scope.control_set = 'record-preflight'

  $scope.$root.$on 'start_edit_rule', (msg, args) ->
    $scope.control_set = 'recording'

  $scope.$root.$on 'end_edit_rule', (msg, args) ->
    $scope.control_set = 'testing'

  $scope.$root.$on 'set_tool', (msg, args) ->
    $scope.$apply() unless $scope.$$phase

  # -- Testing Controls -- #

  $scope.set_running = (r) ->
    window.Game.running = r

  $scope.step = () ->
    window.Game.update(true)

  $scope.step_back = () ->
    window.Game.frameRewind()

  $scope.set_start_state = () ->
    window.Game.setStartState()

  $scope.reset_to_start_state = () ->
    window.Game.resetToStartState()

  $scope.start_state_src = () ->
    window.Game.mainStage.startThumbnail

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
    if t == 'record' && $scope.control_set != 'testing'
      return alert("You're already recording a rule! Exit the recording mode by clicking 'Cancel' or 'Save Recording' and then try again.")
    window.Game.setTool(t)

  $scope.choose_stage_background = () ->
    filepicker.setKey('ALlMNOVpIQNieyu71mvIMz')
    filepicker.pick {
      mimetypes: ['image/*'],
      container: 'window',
      services:['COMPUTER', 'IMAGE_SEARCH', 'FLICKR', 'GOOGLE_DRIVE', 'DROPBOX', 'URL', 'WEBCAM'],
    },
    (InkBlob) ->
      filepicker.convert(InkBlob, {
          fit: 'clip',
          width:window.Game.mainStage.canvas.width,
          height:window.Game.mainStage.canvas.height,
          format: 'jpg',
          quality: 85,
        },{
            location:"S3",
            access: 'public'
        },
        (InkBlob) ->
          window.Game.setStageBackground(InkBlob.key)
        ,
        (FPError) ->
          console.log(FPError.toString())
        ,
        (percent) ->
          console.log(percent)
      )
    ,
    (FPError) ->
      console.log(FPError.toString())


  $scope.definition_name = () ->
    return undefined unless window.Game && window.Game.selectedDefinition
    window.Game.selectedDefinition.name

  # -- Recording Controls -- #

  $scope.start_recording = () ->
    window.Game.editRule(window.Game.selectedRule, window.Game.selectedRule.actor, true)


  $scope.cancel_recording = () ->
    window.Game.revertRecording()
    window.Game.exitRecordingMode()


  $scope.save_recording = () ->
    if window.Game.selectedRule.actions.length == 0
      return alert("Your rule doesn't do anything! Change the scene in the right picture to create actions and then save your rule!")

    window.Game.saveRecording()
    window.Game.exitRecordingMode()


  $scope.recording_descriptors = () ->
    window.Game?.selectedRule?.descriptorsInScenario()

  $scope.recording_actions = () ->
    window.Game?.selectedRule?.actions

  $scope.recording_action_modified = () ->
    window.Game?.recordingActionModified()

  $scope.toggle_appearance_constraint = (ref) ->
    descriptor = window.Game?.selectedRule?.descriptors[ref]
    descriptor.appearance_ignored = !descriptor.appearance_ignored

  $scope.toggle_variable_constraint = (ref, variable_id) ->
    descriptor = window.Game?.selectedRule?.descriptors[ref]
    constraint = descriptor.variableConstraints[variable_id]
    constraint.ignored = !constraint.ignored

  $scope.html_for_actor = (ref, possessive) ->
    name = $scope.name_for_referenced_actor(ref)
    name += "'s" if possessive
    "<code><img src=\"" + $scope.icon_for_referenced_actor(ref) + "\">" + name + "</code>"

  $scope.html_for_appearance = (ref, appearance) ->
    "<code><img src=\"" + $scope.icon_for_referenced_actor(ref,appearance) + "\">" + $scope.name_for_appearance(ref,appearance) + "</code>"

  $scope.icon_for_referenced_actor = (ref, appearance_id = null) ->
    descriptor = window.Game?.selectedRule?.descriptors[ref]
    appearance_id ||= descriptor.appearance
    definition = window.Game.library.definitions[descriptor.definition_id]
    definition.iconForAppearance(appearance_id, 26, 26) || ""

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
    return "Unknown" unless ref
    descriptor = window.Game?.selectedRule?.descriptors[ref]
    return "Unknown" unless descriptor
    definition = window.Game.library.definitions[descriptor.definition_id]
    definition.name

  $scope.name_for_appearance = (ref, id) ->
    descriptor = window.Game?.selectedRule?.descriptors[ref]
    return "Unknown" unless descriptor
    definition = window.Game.library.definitions[descriptor.definition_id]
    return "Unknown" unless definition
    return definition.nameForAppearance(id)

  $scope.name_for_variable = (id) ->
    for key,definition of window.Game.library.definitions
      entry = definition.variables()[id]
      continue unless entry
      return entry.name

  $scope.class_for_appearance_constraint = (descriptor) ->
    return 'condition ignored' if descriptor.appearance_ignored
    return 'condition'

  $scope.class_for_variable_constraint = (constraint) ->
    return 'condition ignored' if constraint.ignored
    return 'condition'

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