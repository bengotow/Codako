
class GameManager

  constructor: (stagePane1, stagePane2, renderingStage) ->
    @library = new LibraryManager('default', @loadStatusChanged)
    @content = new ContentManager(@loadStatusChanged)
    @selectedActor = null

    @recordingActor = null
    @recordingRule = null

    @tool = 'pointer'

    @simulationFrameRate = 500
    @simulationFrameNextTime = 0
    @prevFrames = []

    @elapsed = 0
    @running = false

    @keysDown = {}

    $('body').keydown (e) =>
      if $(e.target).prop('tagName') != 'INPUT' && (e.keyCode == 127 || e.keyCode == 8)
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


  load: (identifier, callback = null) ->
    @dispose()
    @identifier = identifier
    @loadStatusChanged({progress: 0})

    window.Socket.emit 'get-level', {identifier: @identifier}
    window.Socket.on 'level', (data) =>
      console.log('Got Level Data', data)
      return unless data.identifier == @identifier
      @loadLevelDataReady(data)
      callback(null) if callback


  loadStatusChanged: (state) =>
    if (state.progress < 100)
      @mainStage.setStatusMessage("Downloading #{state.progress}%")
    else
      @mainStage.setStatusMessage(null)


  loadLevelDataReady: (json) ->
    console.log('loadLevelDataReady')
    @mainStage.prepareWithData json, (err) =>
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
      window.rulesScope.$apply()
      window.variablesScope.$apply()
      @mainStage.update(elapsed)
    else
      @stagePane1.update(elapsed) if @stagePane1.onscreen()
      @stagePane2.update(elapsed) if @stagePane2.onscreen()


  frameRewind: () ->
    return alert("Sorry, you can't rewind any further!") unless @prevFrames.length
    @selectedActor = null
    @mainStage.prepareWithData @prevFrames.pop(), () ->
      window.rulesScope.$apply()
      window.variablesScope.$apply()


  frameSave: () ->
    @prevFrames = @prevFrames[1..-1] if @prevFrames.length > 20
    @prevFrames.push(@mainStage.saveData())


  frameAdvance: () ->
    for actor in @mainStage.actors
      actor.resetRulesApplied()
      actor.tickRules()
      actor.clickedInCurrentFrame = false

    @keysDown = {}
    @simulationFrameNextTime = Ticker.getTime() + @simulationFrameRate


  dispose: ->
    @selectedActor = null
    @stagePane1.actors = []
    @stagePane1.removeAllChildren()
    @stagePane1.update()
    @stagePane2.actors = []
    @stagePane2.removeAllChildren()
    @stagePane2.update()
    try
      @content.pauseSound('globalMusic')


  save: () ->
    data = @mainStage.saveData()
    data.identifier = @identifier
    window.Socket.emit 'put-level', data

  isKeyDown: (code) ->
    return @keysDown[code]


  # -- Selecting Actors in the World -- #

  addActor: (descriptor) ->
    @mainStage.addActor(descriptor)

  isDescriptorValid: (descriptor) ->
    @mainStage.isDescriptorValid(descriptor)

  actorsAtPosition: (position) ->
    @mainStage.actorsAtPosition(position)

  actorIdentifiers: () ->
    @mainStage.actorIdentifiers()

  actorsAtPositionMatchDescriptors: (position, descriptors) ->
    @mainStage.actorsAtPositionMatchDescriptors(position,descriptors)

  actorMatchingDescriptor: (position, descriptor) ->
    @mainStage.actorMatchingDescriptor(position, descriptor)

  removeActor: (index) ->
    @mainStage.removeActor(index)


  selectActor: (actor) ->
    return if @selectedActor == actor

    @selectedActor.setSelected(false) if @selectedActor
    @selectedDefinition = null

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
        @removeActor(actor)
        @save()
      if @tool == 'record'
        @enterRecordingModeForActor(actor)

    @resetToolAfterAction()


  onActorDoubleClicked: (actor) ->
    @selectActor(actor)
    window.rootScope.$digest()


  onActorDragged: (actor) ->
    @save()


  onAppearancePlaced: (stage) ->
    @update()
    if stage == @mainStage
      @save()

  onActorPlaced: (stage) ->
    @update()
    if stage == @mainStage
      @save()


  # -- Recording Mode -- #

  enterRecordingModeForActor: (actor) ->
    return unless actor
    window.rootScope.$broadcast('start_compose_rule')
    initialExtent = {left: actor.worldPos.x, right: actor.worldPos.x, top: actor.worldPos.y, bottom: actor.worldPos.y}
    @mainStage.setRecordingMaskStyle('masked')
    @mainStage.setRecordingExtent(initialExtent)
    @mainStage.setRecordingCentered(false)
    @recordingActor = actor
    @recordingRule = @computeRecordedRule()
    @selectActor(actor)


  focusAndStartRecording: () ->
    @stagePane1.draggingEnabled = false
    @stagePane2.prepareWithData @mainStage.saveData(), () =>
      @stagePane2.setRecordingExtent(@stagePane1.recordingExtent)

      for stage in [@stagePane1, @stagePane2]
        stage.setRecordingCentered(true)
        stage.setRecordingMaskStyle('white')

      @stagePane1.setWidth(@stageTotalWidth / 2 - 2)
      @stagePane2.setWidth(@stageTotalWidth / 2 - 2)

      # select the recording actor on the right side so the user
      # can jump into changing variables
      @selectActor(@stagePane2.actorMatchingDescriptor(@recordingActor.descriptor()))


  exitRecordingMode: () ->
    @stagePane1.setRecordingCentered(false)
    @stagePane1.setRecordingExtent(null)
    @stagePane1.centerOnEntireCanvas()
    @stagePane1.draggingEnabled = true

    @stagePane1.setWidth(@stageTotalWidth)
    @stagePane2.setWidth(0)

    @selectActor(@recordingActor)
    @recordingActor = null


  recordingHandleDragged: (handle, finished = false) =>
    @extent = @mainStage.recordingExtent
    @extent.left = Math.min(@recordingActor.worldPos.x, handle.worldPos.x + 1, @extent.right) if handle.side == 'left'
    @extent.right = Math.max(@recordingActor.worldPos.x, @extent.left, handle.worldPos.x - 1) if handle.side == 'right'
    @extent.top = Math.min(@recordingActor.worldPos.y, handle.worldPos.y + 1, @extent.bottom) if handle.side == 'top'
    @extent.bottom = Math.max(@recordingActor.worldPos.y, @extent.top, handle.worldPos.y - 1) if handle.side == 'bottom'
    @stagePane1.setRecordingExtent(@extent)
    @stagePane2.setRecordingExtent(@extent)


  computeRecordedRule: () ->
    rule =
      _id: Math.createUUID()
      name: 'Untitled Rule',
      scenario: []

    extent = @stagePane1.recordingExtent
    relX = @recordingActor.worldPos.x
    relY = @recordingActor.worldPos.y
    afterActors = []
    coordStructs = {}

    for x in [extent.left..extent.right]
      for y in [extent.top..extent.bottom]
        afterActors = afterActors.concat(@stagePane2.actorsAtPosition(new Point(x,y)) || [])

    for x in [extent.left..extent.right]
      for y in [extent.top..extent.bottom]
        coord = "#{x - relX},#{y - relY}"
        actors = @stagePane1.actorsAtPosition(new Point(x,y))
        descriptors = []
        for before in actors
          struct = before.descriptor()
          delete struct.position
          delete struct._id

          # find the matching actor in the after scene
          after = _.find afterActors, (a) -> a._id == before._id

          # determine changes and push them onto the descriptor
          struct.actions = before.computeActionsToBecome(after)
          descriptors.push(struct)

          # remove the after actor so it can no longer be referenced.
          # this helsp us determine what has been added in the end
          afterActors = _.reject afterActors, (a) -> a._id == before._id

        coordStructs[coord] = {coord:coord, descriptors: descriptors}
        rule.scenario.push(coordStructs[coord])

    for newActor in afterActors
      coord = "#{newActor.worldPos.x - relX},#{newActor.worldPos.y - relY}"
      coordStructs[coord].added ||= []
      coordStructs[coord].added.push(newActor.descriptor())

    rule


  saveRecording: () ->
    # first, identify changes to each actor we started with
    rule = @computeRecordedRule()

    # okay cool - now add the rule to the actor definition
    @recordingActor.definition.addRule(rule)
    @exitRecordingMode()


  # -- Helper Methods -- #

  renderRuleScenario: (scenario, applyActions = false) ->
    # Creating a random background based on the 3 layers available in 3 versions
    @renderingStage.addChild(new Bitmap(@content.imageNamed('Layer0_0')))

    xmin = xmax = ymin = ymax = 0
    for block in scenario
      coord = Point.fromString(block.coord)
      xmin = Math.min(xmin, coord.x)
      xmax = Math.max(xmax, coord.x)
      ymin = Math.min(ymin, coord.y)
      ymax = Math.max(ymax, coord.y)

    @renderingStage.canvas.width = (xmax - xmin + 1) * Tile.WIDTH
    @renderingStage.canvas.height = (ymax - ymin + 1) * Tile.HEIGHT

    for block in scenario
      coord = Point.fromString(block.coord)
      for descriptor in block.descriptors
        actor = window.Game.library.instantiateActorFromDescriptor(descriptor)
        actor.nextPos = new Point(-xmin + coord.x, -ymin + coord.y)
        actor.tick()
        actor.applyActions(descriptor.actions) if applyActions
        actor.tick()
        @renderingStage.addChild(actor)

      continue unless block.added
      for descriptor in block.added
        descriptor = JSON.parse(JSON.stringify(descriptor))
        descriptor.position = new Point(-xmin + coord.x, -ymin + coord.y)
        actor = window.Game.library.instantiateActorFromDescriptor(descriptor)
        actor.tick()
        @renderingStage.addChild(actor)



    @renderingStage.update()
    data = @renderingStage.canvas.toDataURL()
    @renderingStage.removeAllChildren()
    data


window.GameManager = GameManager
window.Tile =
  WIDTH: 40
  HEIGHT: 40

