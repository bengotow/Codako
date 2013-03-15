
class Level

  constructor: (stage, identifier) ->
    @identifier = identifier
    @stage = stage
    @actors = []
    @selectedActor = null

    @ruleCheckInterval = 0.40
    @ruleCheckNextElapsed = 0
    @elapsed = 0

    @keysDown = {}
    document.onkeydown = (e) =>
      @keysDown[e.keyCode] = true


    # Make the canvas droppable - a bit of a hack
    @stage.canvas.ondrop = (e, dragEl) =>
      identifier = $(dragEl.draggable).data('identifier')
      parentOffset = $(@stage.canvas).parent().offset()
      point = new Point(Math.round((e.pageX - e.offsetX - parentOffset.left) / Tile.WIDTH), Math.round((e.pageY - e.offsetY - parentOffset.top) / Tile.HEIGHT))
      if identifier[0..4] == 'actor'
        @onActorPlaced({identifier: identifier[6..-1], position: point})
      else if identifier[0..9] == 'appearance'
        @onAppearancePlaced(identifier[11..-1], point)


    # Creating a random background based on the 3 layers available in 3 versions
    background = new Bitmap(window.Game.Content.imageNamed('Layer0_0'))
    background.addEventListener 'click', (e) =>
      @onActorClicked(null)
    @stage.addChild(background)
    @


  getBounds: (x, y) ->
    new XNARectangle(x * Tile.WIDTH, y * Tile.HEIGHT, Tile.WIDTH, Tile.HEIGHT)


  dispose: ->
    @stage.removeAllChildren()
    @stage.update()
    try
      window.Game.Content.pauseSound('globalMusic')


  load: (callback) ->
    console.log('Requesting Level Data')
    window.Socket.emit 'get-level', {identifier: @identifier}
    window.Socket.on 'level', (data) =>
      console.log('Got Level Data', data)
      return unless data.identifier == @identifier
      @loadDataReady(data)
      callback(null)


  loadDataReady: (json) ->
    @width = json['width']
    @height = json['height']
    @tiles = Array.matrix(@height, @width, "|")

    # make sure all of the actors on the stage are in the library
    for actor in json.actor_descriptors
      json.actor_library.push(actor.identifier) if json.actor_library.indexOf(actor.identifier) == -1

    # fetch the actor definitions (which include base64 image data, etc...)
    window.Game.Library.loadActorDefinitions json.actor_library, (err) =>
      console.log('Got Actor Data')
      @initialGameTime = Ticker.getTime()
      @addActor(descriptor) for descriptor in json['actor_descriptors']


  updatedDataReady: () ->
    for actor in @actors
      actor.createSpriteSheet(actor.definition.img, actor.definition.spritesheet.animations)


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


  addActor: (descriptor) ->
    actor = window.Game.Library.instantiateActorFromDescriptor(descriptor, @)
    return console.log('Could not read descriptor:', descriptor) if !actor
    actor.addEventListener 'click', (e) =>
      @onActorClicked(actor)
    @actors.push(actor)
    @stage.addChild(actor)


  isKeyDown: (code) ->
    return @keysDown[code]


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


  update: ->
    elapsed = (Ticker.getTime() - @initialGameTime) / 1000

    for actor in @actors
      actor.tick(elapsed)

    if elapsed > @ruleCheckNextElapsed
      for actor in @actors
        actor.resetRulesApplied()
        actor.tickRules()

      @keysDown = {}
      @ruleCheckNextElapsed += @ruleCheckInterval
      window.rulesScope.$apply()

    @stage.update()


  onActorClicked: (actor) ->
    @selectedActor.setSelected(false) if @selectedActor
    @selectedDefinition = null

    @selectedActor = actor
    @selectedDefinition = @selectedActor.definition if @selectedActor
    @selectedActor.setSelected(true) if @selectedActor
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


  window.Level = Level
