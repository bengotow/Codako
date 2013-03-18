class GameStage extends Stage

  constructor: (canvas) ->
    GameStage.__super__.initialize.call(this, canvas)
    @recordingHandles = {}
    @recordingMasks = []
    @recordingMaskStyle = 'masked'
    @recordingExtent = {}
    @recordingCentered = false
    @offsetTarget = new Point(0,0)
    @statusMessage = null
    @draggingEnabled = true
    @actors = []

    @canvas.ondrop = (e, dragEl) =>
      identifier = $(dragEl.draggable).data('identifier')
      parentOffset = $(@canvas).parent().offset()

      # account for the stage's transform
      e.pageX = e.pageX - @x - $(_this.canvas).offset().left
      e.pageY = e.pageY - @y

      # compute grid point
      point = new Point(Math.round((e.pageX - e.offsetX) / Tile.WIDTH), Math.round((e.pageY - e.offsetY - parentOffset.top) / Tile.HEIGHT))

      if identifier[0..4] == 'actor'
        @addActor({identifier: identifier[6..-1], position: point})
        window.Game.onActorPlaced(@)

      else if identifier[0..9] == 'appearance'
        for actor in @actorsAtPosition(point)
          actor.setAppearance(identifier[11..-1])
        window.Game.onAppearancePlaced(@)


  saveData: () ->
    data =
      identifier: @identifier
      width: @width,
      height: @height,
      actor_library: @actorIdentifiers(),
      actor_descriptors: []
    data.actor_descriptors.push(actor.descriptor()) for actor in @actors

    console.log 'Created Save Data:', data
    data


  prepareWithData: (json, callback) ->
    @removeAllChildren()
    @actors = []

    @width = json['width']
    @height = json['height']

    # Creating a random background based on the 3 layers available in 3 versions
    background = new Bitmap(window.Game.content.imageNamed('Layer0_0'))
    background.addEventListener 'click', (e) =>
      window.Game.onActorClicked(null)
    background.addEventListener 'dblclick', (e) =>
      window.Game.onActorDoubleClicked(null)
    @addChild(background)

    # make sure all of the actors on the stage are in the library
    for actor in json.actor_descriptors
      json.actor_library.push(actor.identifier) if json.actor_library.indexOf(actor.identifier) == -1

    # fetch the actor definitions (which include base64 image data, etc...)
    window.Game.library.loadActorDefinitions json.actor_library, (err) =>
      for descriptor in json.actor_descriptors
        @addActor(descriptor)
      callback(null) if callback


  setStatusMessage: (message) =>
    if (message)
      # add a text object to output the current donwload progression
      if !@statusMessage
        @statusMessage = new Text("-- %", "bold 14px Arial", "#FFF")
        @statusMessage.x = (@width / 2) - 50
        @statusMessage.y = @height / 2
        @addChild(@statusMessage)

      @statusMessage.text = message
      @update()
    else
      @removeChild(@statusMessage)
      @statusMessage = null


  setRecordingExtent: (extent) ->
    # Remove existing elements
    console.log('Updating Recording Extent', @recordingExtent)
    @recordingExtent = extent

    for obj in @recordingMasks
      @removeChild(obj)
    @recordingMasks = []

    for key, obj of @recordingHandles
      @removeChild(obj)
    @recordingHandles = {}

    return unless extent

    # Add gray mask outside of the recording region
    for x in [0..@width]
      for y in [0..@height]
        if (x < extent.left || x > extent.right) || (y < extent.top || y > extent.bottom)
          sprite = new SquareMaskSprite(@recordingMaskStyle)
          sprite.x = x * Tile.WIDTH
          sprite.y = y * Tile.HEIGHT
          @addChild(sprite)
          @recordingMasks.push(sprite)

    # Add the handles
    for side in ['top', 'left', 'right', 'bottom']
      @recordingHandles[side] = new HandleSprite(side, extent)
      @recordingHandles[side].positionWithExtent(extent)
      @addChild(@recordingHandles[side])

    @centerOnRecordingRegion() if @recordingCentered


  setRecordingMaskStyle: (type) ->
    @recordingMaskStyle = type
    @setRecordingExtent(@recordingExtent)


  setRecordingCentered: (centered) ->
    @recordingCentered = centered
    @centerOnRecordingRegion() if @recordingCentered
    @update()


  centerOnRecordingRegion: () ->
    @offsetTarget.x = (4.5 - @recordingExtent.left - (@recordingExtent.right - @recordingExtent.left) / 2) * Tile.WIDTH
    @offsetTarget.y = (5 - @recordingExtent.top - (@recordingExtent.bottom - @recordingExtent.top) / 2) * Tile.HEIGHT


  centerOnEntireCanvas: () ->
    @offsetTarget.x = @offsetTarget.y = 0


  update: (elapsed) ->
    super

    for actor in @actors
      actor.tick(elapsed)

    @x += (@offsetTarget.x - @x) / 5
    @y += (@offsetTarget.y - @y) / 5


  # -- Managing Actors on the Stage -- #

  addActor: (descriptor) ->
    actor = window.Game.library.instantiateActorFromDescriptor(descriptor, @)
    return console.log('Could not read descriptor:', descriptor) if !actor

    actor.addEventListener 'click', (e) =>
      window.Game.onActorClicked(actor)
    actor.addEventListener 'dblclick', (e) =>
      window.Game.onActorDoubleClicked(actor)
    actor.stage = @

    @actors.push(actor)
    @addChild(actor)


  isDescriptorValid: (descriptor) ->
    @actorMatchingDescriptor(descriptor)?


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


  actorMatchingDescriptor: (descriptor, set = @actors) ->
    for actor in set
      return actor if actor.matchesDescriptor(descriptor)
    false


  removeActor: (index_or_actor) ->
    if index_or_actor instanceof Sprite
      @removeChild(index_or_actor)
      @actors.splice(@actors.indexOf(index_or_actor),1)
    else
      @removeChild(@actors[index_or_actor])
      @actors.splice(index_or_actor,1)


  removeActorsMatchingDescriptor: (descriptor) ->
    for x in [@actors.length - 1..0] by -1
      @removeActor(x) if @actors[x].matchesDescriptor(descriptor)


window.GameStage = GameStage