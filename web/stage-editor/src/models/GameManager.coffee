
class GameManager

  constructor: (stagePane1, stagePane2, renderingStage) ->
    @world_id = null
    @stage_id = null

    @library = new LibraryManager('default', @loadStatusChanged)
    @content = new ContentManager(@loadStatusChanged)
    @selectedActor = null
    @selectedRule = null

    @tool = 'pointer'

    @simulationFrameRate = 500
    @simulationFrameNextTime = 0
    @prevFrames = []

    @elapsed = 0
    @running = false

    @keysDown = {}

    $('body').keydown (e) =>
      return if $(e.target).prop('tagName') == 'INPUT'
      return if $(e.target).prop('id') == 'pixelArtModal'
      return if $(e.target).prop('id') == 'keyInputModal'

      if e.keyCode == 127 || e.keyCode == 8
        e.preventDefault()
        @selectedActor.stage.removeActor(@selectedActor) if @selectedActor
        @selectActor(null)
        @save()

      @keysDown[e.keyCode] = true

    document.onkeyup = (e) =>
      @keysDown[e.keyCode] = false if !@running

    @mainStage = @stagePane1 = stagePane1
    @stagePane2 = stagePane2
    @stageTotalWidth = @stagePane1.canvas.width

    @renderingStage = renderingStage
    @


  load: (world_id, stage_id, callback = null) ->
    @dispose()
    @world_id = world_id
    @stage_id = stage_id
    @loadStatusChanged({progress: 0})

    $.ajax({url: "/api/v0/worlds/#{world_id}/stages/#{stage_id}"})
      .done (stage) =>
        stage.resources ||= {images: {}, sounds: {}}
        @content.fetchLevelAssets stage.resources, () =>
          @loadLevelDataReady(stage)
          callback(null) if callback


  loadStatusChanged: (state) =>
    if (state.progress < 100)
      @mainStage.setStatusMessage("Downloading #{state.progress}%")
    else
      @mainStage.setStatusMessage(null)


  loadLevelDataReady: (data) ->
    @mainStage.prepareWithData data, (err) =>
      @loadStatusChanged({progress: 100})
      @initialGameTime = Ticker.getTime()

      @update()

      Ticker.addListener(@)
      Ticker.useRAF = false
      Ticker.setFPS(30)
      window.rootScope.$apply()


  tick: () ->
    @update()


  update: (forceRules = false) ->
    time = Ticker.getTime()
    elapsed = (time - @initialGameTime) / 1000

    if (@running && time > @simulationFrameNextTime) || forceRules
      @frameSave()
      @frameAdvance()
      window.rulesScope.$apply() unless window.rulesScope.$$phase
      window.variablesScope.$apply() unless window.variablesScope.$$phase
      @mainStage.update(elapsed)
    else
      @stagePane1.update(elapsed) if @stagePane1.onscreen()
      @stagePane2.update(elapsed) if @stagePane2.onscreen()


  frameRewind: () ->
    return alert("Sorry, you can't rewind any further!") unless @prevFrames.length
    @selectedActor = null
    @mainStage.prepareWithData @prevFrames.pop(), () ->
      window.rulesScope.$apply() unless window.rulesScope.$$phase
      window.variablesScope.$apply() unless window.variablesScope.$$phase


  frameSave: () ->
    if @selectedRule?.editing
      throw "This shouldn't happen!"
    @prevFrames = @prevFrames[1..-1] if @prevFrames.length > 20
    @prevFrames.push(@mainStage.saveData())


  frameAdvance: () ->
    # if we create new actors during the frame, we don't want to advance
    # those ones. Existing actors only!
    actorsPresentBeforeFrame = [].concat(@mainStage.actors)

    for x in [actorsPresentBeforeFrame.length - 1..0] by -1
      actor = actorsPresentBeforeFrame[x]
      actor.resetRulesApplied()
      actor.tickRules()
      actor.clickedInCurrentFrame = false

    @keysDown = {}
    @simulationFrameNextTime = Ticker.getTime() + @simulationFrameRate


  dispose: ->
    @selectedActor = null
    @stagePane1.dispose()
    @stagePane2.dispose()
   try
      @content.pauseSound('globalMusic')


  save: (options = {}) ->
    if @selectedRule && @selectedRule.editing
      console.log('Trying to save while editing a rule??')
      return

    isAsync = true
    isAsync = options.async if options.async != undefined

    $.ajax({
      url: "/api/v0/worlds/#{@world_id}/stages/#{@stage_id}",
      data: angular.toJson(@mainStage.saveData(options)),
      contentType: 'application/json',
      type: 'POST',
      async: isAsync
    }).done () ->
      console.log('Stage Saved')


  isKeyDown: (code) ->
    return @keysDown[code]


  # -- Selecting Actors in the World -- #

  selectActor: (actor) ->
    return if @selectedActor == actor

    @selectedActor.setSelected(false) if @selectedActor
    @selectedDefinition = null

    # applying the changes forces the sidebars and panels to take on the
    # blank state before they take on another actor's state. This is important
    # because switching from one hash data source to another isn't noticed
    # by Angular's change tracking system
    window.rootScope.$apply() unless window.rootScope.$$phase

    @selectedActor = actor
    @selectedDefinition = @selectedActor.definition if @selectedActor
    @selectedActor.setSelected(true) if @selectedActor


  selectDefinition: (definition) ->
    @selectedActor.setSelected(false) if @selectedActor
    @selectedDefinition = definition


  setTool: (t) ->
    $('body').removeClass("tool-#{@tool}")
    @tool = t
    $('body').addClass("tool-#{@tool}")
    window.rootScope.$broadcast('set_tool', 'pointer')


  resetToolAfterAction: () ->
    canRepeat = @tool == 'delete'
    @setTool('pointer') unless canRepeat && (@keysDown[16] || @keysDown[17] || @keysDown[18])


  # -- Event Handling from the World and GameStage --- #

  onActorClicked: (actor) =>
    if actor
      actor.clickedInCurrentFrame = true if @running

      if @tool == 'paint'
        window.rootScope.$broadcast('edit_appearance', {actor_definition: actor.definition, identifier: actor.appearance})
      if @tool == 'delete'
        @onActorDeleted(actor, actor.stage)
      if @tool == 'record'
        @editNewRuleForActor(actor)

    @resetToolAfterAction()


  onActorDoubleClicked: (actor) ->
    @selectActor(actor)
    window.rootScope.$digest()


  onActorVariableValueEdited: (actor, varName, val) ->
    @wrapApplyChangeTo actor, actor.stage, () ->
      actor.variableValues[varName] = val


  onActorDragged: (actor, stage, point) ->
    if @selectedRule
      return unless point.isInside(@mainStage.recordingExtent)

    @wrapApplyChangeTo actor, stage, () ->
      actor.setWorldPos(point)


  onActorDeleted: (actor, stage) ->
    @wrapApplyChangeTo actor, stage, () ->
      stage.removeActor(actor)


  onAppearancePlaced: (actor, stage, appearance) ->
    @wrapApplyChangeTo actor, stage, () =>
      actor.setAppearance(appearance)
      @update()


  onActorPlaced: (actor, stage) ->
    @wrapApplyChangeTo actor, stage, () =>
      @update()


  wrapApplyChangeTo: (actor, stage, applyCallback) ->
    applyCallback()

    if @selectedRule
      if stage == @stagePane1
        # make sure that the extent of the recording is not changed by moving the
        # recording actor.
        extent = @selectedRule.extentOnStage()
        @selectedRule.setMainActor(actor) if actor._id == @selectedRule.actor._id
        @selectedRule.updateScenario(@stagePane1, extent)


        # make sure that any changes to the scenario that are not related to an action
        # are mirrored onto the "after" scenario. For example if I add a new actor to
        # the before scenario, that doesn't mean has was deleted in the after scenario.
        # If I change variable A to 10, and A is not involved in an action, it should be
        # 10 in the after picture as well.
        @selectedRule.updateActions(@stagePane1, @stagePane2, {existingActionsOnly: true, skipVariables: true, skipAppearance: true})

        @mirrorStage1OntoStage2 {}, () =>
          # If I change variable A and A is tied to an action, update it. Otherwise ignore.
          # If I change the position of X and X is moved to a new spot in the after picture, update.
          @selectedRule.updateActions(@stagePane1, @stagePane2, {existingActionsOnly: true, skipMove: true})


      if stage == @stagePane2 && @stagePane2.onscreen()
        @selectedRule.updateActions(@stagePane1, @stagePane2)

    else
      if stage == @mainStage
        @save()

  # -- Managing the Background -- #
  setStageBackground: (background_key) ->
    @stagePane1.setBackground(background_key, true)
    @stagePane2.setBackground(background_key, true)
    @save()


  # -- Managing the Stage Start State -- #
  setStartState: () =>
    return if @selectedRule
    @mainStage.setStartState()
    @save()


  resetToStartState: () =>
    return if @selectedRule
    @selectActor(null)
    @mainStage.resetToStartState()


  # -- Recording Mode -- #

  editNewRuleForActor: (actor) ->
    return unless actor
    window.rootScope.$broadcast('start_compose_rule')
    initialExtent = {left: actor.worldPos.x, right: actor.worldPos.x, top: actor.worldPos.y, bottom: actor.worldPos.y}

    @selectedRule = new Rule()
    @selectedRule.setMainActor(actor)
    @selectedRule.updateScenario(@mainStage, initialExtent)

    @mainStage.setRecordingExtent(initialExtent, 'masked')
    @mainStage.setRecordingCentered(false)
    @selectActor(actor)


  editRule: (rule, actor = null, isNewRule = false) ->
    return unless rule
    @saveRecording() if @selectedRule && @selectedRule != rule
    @selectActor(actor) if actor && @selectedActor != actor
    @selectedRule = rule
    @enterRecordingMode(isNewRule)


  enterRecordingMode: (demonstrateOnCurrentStage = false) ->
    window.rootScope.$broadcast('start_edit_rule')

    @previousRuleState = JSON.parse(JSON.stringify(@selectedRule.descriptor()))
    @previousGameState = @mainStage.saveData() unless @previousGameState
    @selectedRule.editing = true

    extent = null

    _beforeStageReady = () =>
      @stagePane1.setRecordingExtent(extent, 'white')
      @stagePane1.setRecordingCentered(true)
      @stagePane1.setDisplayWidth(@stageTotalWidth / 2 - 2)

      # we have to give the rule the correct main actor, or the relative coords on the
      # scenario won't match! Find the actor in the 0,0 block of the rule that matches
      # the descriptor of the selected actor
      extentRelative = @selectedRule.extentRelativeToRoot()
      extentRootPos = new Point(-extentRelative.left + extent.left, -extentRelative.top + extent.top)

      actor = @stagePane1.actorMatchingDescriptor(@selectedRule.mainActorDescriptor(), @stagePane1.actorsAtPosition(extentRootPos))
      @selectedRule.setMainActor(actor)
      @selectActor(actor) if @selectedActor != actor

      @mirrorStage1OntoStage2({shouldSelect: true})

    if demonstrateOnCurrentStage
      extent = @selectedRule.extentOnStage()
      @stagePane1.draggingEnabled = false
      _beforeStageReady()
    else
      stageData = @selectedRule.beforeSaveData(6, 6)
      extent = stageData.extent
      @stagePane1.draggingEnabled = true
      @stagePane1.prepareWithData stageData, _beforeStageReady


  mirrorStage1OntoStage2: (options = {}, callback) ->
    options.shouldSelect ||= @selectedActor?.stage == @stagePane2

    @stagePane2.prepareWithData @mainStage.saveData(), () =>
      # make the secondary pane visible and update extent to match
      @stagePane2.setRecordingExtent(@mainStage.recordingExtent, 'white')
      @stagePane2.setRecordingCentered(true)
      @stagePane2.setDisplayWidth(@stageTotalWidth / 2 - 2)

      # perform the rule, so the second pane reflects the "After" state
      ruleActor = @stagePane2.actorWithID(@selectedRule.actor._id)
      ruleActor.applyRule(@selectedRule)

      # select the actor that was selected before we reloaded the data
      actorToSelect = @selectedActor || @selectedRule.actor
      @selectActor(@stagePane2.actorWithID(actorToSelect._id)) if actorToSelect && options.shouldSelect

      # continue on to post-setup
      callback() if callback


  exitRecordingMode: () ->
    window.rootScope.$broadcast('end_edit_rule')

    @stagePane1.clearRecording()
    @stagePane1.setDisplayWidth(@stageTotalWidth)
    @stagePane2.clearRecording()
    @stagePane2.setDisplayWidth(0)

    if @previousGameState
      @stagePane1.prepareWithData @previousGameState, () =>
        if @selectedRule.actor
          previouslySelectedActor = @stagePane1.actorWithID(@selectedRule.actor._id)
          @selectActor(previouslySelectedActor) if previouslySelectedActor

        @previousGameState = undefined
        @previousRuleState = undefined

    @selectedRule = null


  recordingActionModified: () =>
    @mirrorStage1OntoStage2()


  recordingHandleDragged: (handle, finished = false) =>
    extent = @mainStage.recordingExtent
    extent.left = Math.min(handle.worldPos.x + 1, extent.right) if handle.side == 'left'
    extent.right = Math.max(extent.left, handle.worldPos.x - 1) if handle.side == 'right'
    extent.top = Math.min(handle.worldPos.y + 1, extent.bottom) if handle.side == 'top'
    extent.bottom = Math.max(extent.top, handle.worldPos.y - 1) if handle.side == 'bottom'

    extent = @selectedRule.updateExtent(@stagePane1, @stagePane2, extent)
    @stagePane1.setRecordingExtent(extent)
    @stagePane2.setRecordingExtent(extent)
    window.rootScope.$apply() unless window.rootScope.$$phase


  revertRecording: () ->
    @selectedRule[key] = value for key, value of @previousRuleState


  saveRecording: () ->
    actor = @selectedRule.actor
    actor.definition.addRule(@selectedRule)
    actor.definition.clearCacheForRule(@selectedRule)
    actor.definition.save()


  # -- Helper Methods -- #

  renderRule: (rule, applyActions = false) ->
    # Creating a random background based on the 3 layers available in 3 versions
    @renderingStage.canvas.style.backgroundColor = '#ff0000'

    xmin = xmax = ymin = ymax = 0
    created_actors = {}

    for block in rule.scenario
      coord = Point.fromString(block.coord)
      xmin = Math.min(xmin, coord.x)
      xmax = Math.max(xmax, coord.x)
      ymin = Math.min(ymin, coord.y)
      ymax = Math.max(ymax, coord.y)

    @renderingStage.canvas.width = (xmax - xmin + 1) * Tile.WIDTH
    @renderingStage.canvas.height = (ymax - ymin + 1) * Tile.HEIGHT

    # lay out the before state and apply any rules that apply to
    # the actors currently on the board
    @renderingStage.addActor = (ref, offset) =>
      descriptor = rule.descriptors[ref]
      actor = window.Game.library.instantiateActorFromDescriptor(descriptor, new Point(-xmin + offset.x, -ymin + offset.y))
      actor.tick()
      @renderingStage.addChild(actor)
      created_actors[ref] = actor


    for block in rule.scenario
      point = Point.fromString(block.coord)
      for ref in block.refs
        @renderingStage.addActor(ref, point)

    # apply any actions
    if applyActions && rule.actions
      for action in rule.actions
        if action.type == 'create'
          @renderingStage.addActor(action.ref, Point.fromString(action.offset))
        else
          actor = created_actors[action.ref]
          actor.applyRuleAction(action)
          actor.tick()


    @renderingStage.update()
    data = @renderingStage.canvas.toDataURL()
    @renderingStage.removeAllChildren()
    data


window.GameManager = GameManager
window.Tile =
  WIDTH: 40
  HEIGHT: 40

