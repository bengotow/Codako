
class GameManager

  constructor: (stage, renderingStage) ->
    @library = new LibraryManager('default', @loadStatusChanged)
    @content = new ContentManager(@loadStatusChanged)
    @actors = []
    @selectedActor = null
    @width = @height = 0

    @simulationFrameRate = 500
    @simulationFrameNextTime = 0
    @prevFrames = []

    @elapsed = 0
    @running = false

    @keysDown = {}
    document.onkeydown = (e) =>
      @keysDown[e.keyCode] = true

    @stage = stage
    @stage.canvas.ondrop = (e, dragEl) =>
      identifier = $(dragEl.draggable).data('identifier')
      parentOffset = $(@stage.canvas).parent().offset()
      point = new Point(Math.round((e.pageX - e.offsetX - parentOffset.left) / Tile.WIDTH), Math.round((e.pageY - e.offsetY - parentOffset.top) / Tile.HEIGHT))
      if identifier[0..4] == 'actor'
        @onActorPlaced({identifier: identifier[6..-1], position: point})
      else if identifier[0..9] == 'appearance'
        @onAppearancePlaced(identifier[11..-1], point)

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
      # add a text object to output the current donwload progression
      if !@downloadProgress
        @downloadProgress = new Text("-- %", "bold 14px Arial", "#FFF")
        @downloadProgress.x = (@width / 2) - 50
        @downloadProgress.y = @height / 2
        @stage.addChild(@downloadProgress)
      @downloadProgress.text = "Downloading #{state.progress}%"
      @stage.update()
    else
      @stage.removeChild(@downloadProgress)
      @downloadProgress = null


  loadLevelDataReady: (json) ->
    @width = json['width']
    @height = json['height']

    # Creating a random background based on the 3 layers available in 3 versions
    background = new Bitmap(@content.imageNamed('Layer0_0'))
    background.addEventListener 'click', (e) =>
      @onActorClicked(null)
    @stage.addChild(background)

    # make sure all of the actors on the stage are in the library
    for actor in json.actor_descriptors
      json.actor_library.push(actor.identifier) if json.actor_library.indexOf(actor.identifier) == -1

    # fetch the actor definitions (which include base64 image data, etc...)
    @library.loadActorDefinitions json.actor_library, (err) =>
      for descriptor in json.actor_descriptors
        @addActor(descriptor)
      @loadFinished()


  loadFinished: () ->
    @loadStatusChanged({progress: 100})
    @initialGameTime = Ticker.getTime()

    @update()

    Ticker.addListener(@)
    Ticker.useRAF = false
    Ticker.setFPS(60)
    window.rootScope.$apply()


  tick: () ->
    @update()


  update: (forceRules = false) ->
    time = Ticker.getTime()
    elapsed = (time - @initialGameTime) / 1000
    for actor in @actors
      actor.tick(elapsed)

    return @stage.update() unless @running || forceRules

    if forceRules || time > @simulationFrameNextTime
      @frameSave()
      @frameAdvance()
      window.rulesScope.$apply()
      @stage.update()


  frameRewind: () ->
    return alert("Sorry, you can't rewind any further!") unless @prevFrames.length
    frame = @prevFrames.pop()

    @selectedActor = null
    for actor in @actors
      @stage.removeChild(actor)
    @actors = []
    for descriptor in frame
      @addActor(descriptor)
    window.rulesScope.$apply()
    @stage.update()


  frameSave: () ->
    currentFrame = []
    for actor in @actors
      currentFrame.push(actor.descriptor())

    @prevFrames = @prevFrames[1..-1] if @prevFrames.length > 20
    @prevFrames.push(currentFrame)


  frameAdvance: () ->
    for actor in @actors
      actor.resetRulesApplied()
      actor.tickRules()
    @keysDown = {}
    @simulationFrameNextTime = Ticker.getTime() + @simulationFrameRate


  dispose: ->
    @actors = []
    @selectedActor = null
    @stage.removeAllChildren()
    @stage.update()
    try
      @content.pauseSound('globalMusic')


  save: () ->
    data =
      identifier: @identifier
      width: @width,
      height: @height,
      actor_library: @actorIdentifiers(),
      actor_descriptors: []
    data.actor_descriptors.push(actor.descriptor()) for actor in @actors
    console.log 'Saving', data
    window.Socket.emit 'put-level', data


  isKeyDown: (code) ->
    return @keysDown[code]


  # -- Managing Actors in the World -- #

  addActor: (descriptor) ->
    actor = @library.instantiateActorFromDescriptor(descriptor, @)
    return console.log('Could not read descriptor:', descriptor) if !actor
    actor.addEventListener 'click', (e) =>
      @onActorClicked(actor)
    @actors.push(actor)
    @stage.addChild(actor)


  isDescriptorValid: (descriptor) ->
    actorMatchingDescriptor(descriptor)?


  actorsAtPosition: (position) ->
    results = []
    for actor in @actors
      if actor.worldPos.isEqual(position)
        results.push(actor)
    results


  actorIdentifiers: () ->
    ids = []
    for actor in @actors
      ids.push(actor.identifier) if ids.indexOf(actor.identifier) == -1
    ids


  actorsAtPositionMatchDescriptors: (position, descriptors) ->
    searchSet = @actorsAtPosition(position)

    return searchSet.length == 0 if !descriptors

    for actor in searchSet
      matched = false
      for descriptor in descriptors
        matched = true if actor.matchesDescriptor(descriptor)
      return false unless matched

    true


  actorMatchingDescriptor: (position, descriptor) ->
    searchSet = @actorsAtPosition(position)
    for actor in searchSet
      return actor if actor.matchesDescriptor(descriptor)
    false


  removeActor: (index) ->
    @stage.removeChild(@actors[index])
    @actors.splice(index,1)


  removeActorsMatchingDescriptor: (descriptor) ->
    for x in [@actors.length - 1..0] by -1
      @removeActor(x) if @actors[x].matchesDescriptor(descriptor)


  selectActor: (actor) ->
    @selectedActor.setSelected(false) if @selectedActor
    @selectedDefinition = null

    @selectedActor = actor
    @selectedDefinition = @selectedActor.definition if @selectedActor
    @selectedActor.setSelected(true) if @selectedActor


  selectDefinition: (definition) ->
    @selectedActor.setSelected(false) if @selectedActor
    @selectedDefinition = definition


  # -- Event Handling from the World --- #

  onActorClicked: (actor) ->
    @selectActor(actor)
    window.rootScope.$digest()


  onActorDragged: (actor) ->
    @save()


  onAppearancePlaced: (identifier, point) ->
    for actor in @actorsAtPosition(point)
      actor.setAppearance(identifier)
    @update()
    @save()

  onActorPlaced: (actor_descriptor) ->
    @addActor(actor_descriptor)
    @update()
    @save()



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
      for descriptor in block.descriptors
        coord = Point.fromString(block.coord)
        actor = window.Game.library.instantiateActorFromDescriptor(descriptor)
        actor.nextPos = new Point(-xmin + coord.x, -ymin + coord.y)
        actor.tick()
        actor.applyActions(descriptor.actions) if applyActions
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

