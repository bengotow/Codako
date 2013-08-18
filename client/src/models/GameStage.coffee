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
    @width = 20
    @height = 20
    @wrapX = true
    @wrapY = true

    @widthTarget = canvas.width
    @widthCurrent = canvas.width

    @canvas.ondrop = (e, dragEl) =>
      identifier = $(dragEl.draggable).data('identifier')
      parentOffset = $(@canvas).parent().offset()

      # account for the stage's transform
      e.pageX = e.pageX - @x - $(_this.canvas).offset().left
      e.pageY = e.pageY - @y

      # compute grid point
      point = new Point(Math.round((e.pageX - e.offsetX) / Tile.WIDTH), Math.round((e.pageY - e.offsetY - parentOffset.top) / Tile.HEIGHT))

      if identifier[0..4] == 'actor'
        actor = @addActor({identifier: identifier[6..-1], position: point})
        window.Game.onActorPlaced(actor, @)

      else if identifier[0..9] == 'appearance'
        actor = @actorsAtPosition(point)[0]
        window.Game.onAppearancePlaced(actor, @, identifier[11..-1]) if actor

  onscreen: () ->
    @widthTarget > 0 || @widthCurrent > 0


  setDisplayWidth: (width) ->
    @widthTarget = width


  saveData: () ->
    data =
      identifier: @identifier
      width: @width,
      height: @height,
      wrapX: @wrapX,
      wrapY: @wrapY,
      actor_library: @actorIdentifiers(),
      actor_descriptors: []
    data.actor_descriptors.push(actor.descriptor()) for actor in @actors

    console.log 'Created Save Data:', data
    data


  prepareWithData: (json, callback) ->
    @dispose()

    @width = json['width']
    @height = json['height']
    @wrapX = json['wrapX']
    @wrapY = json['wrapY']

    # Creating a random background based on the 3 layers available in 3 versions
    background = new Bitmap(window.Game.content.imageNamed('Layer0_0'))
    background.scaleX = ((@width * Tile.WIDTH) / background.image.width)
    background.scaleY = ((@height * Tile.HEIGHT) / background.image.height)

    background.addEventListener 'click', (e) =>
      window.Game.onActorClicked(null)
    background.addEventListener 'dblclick', (e) =>
      window.Game.onActorDoubleClicked(null)
    @addChild(background)

    # make sure all of the actors on the stage are in the library
    library = json.actor_library || []
    for actor in json.actor_descriptors
      library.push(actor.identifier) if library.indexOf(actor.identifier) == -1

    # fetch the actor definitions (which include base64 image data, etc...)
    window.Game.library.loadActorDefinitions library, (err) =>
      @addActor(descriptor) for descriptor in json.actor_descriptors
      @update()

      callback(null) if callback


  dispose: () =>
    @actors = []
    @recordingMasks = []
    @recordingHandles = {}
    @removeAllChildren()
    @update()


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


  setRecordingExtent: (extent, maskStyle = @recordingMaskStyle) ->
    styleChanged = (maskStyle != @recordingMaskStyle)
    @setRecordingExtent(null) if styleChanged

    @recordingMaskStyle = maskStyle
    @recordingExtent = extent

    for key, obj of @recordingHandles
      @removeChild(obj)
    @recordingHandles = {}

    # Add gray mask outside of the recording region
    usedMasks = 0
    for x in [0..@width]
      for y in [0..@height]
        if extent && ((x < extent.left || x > extent.right) || (y < extent.top || y > extent.bottom))
          if usedMasks < @recordingMasks.length
            sprite = @recordingMasks[usedMasks]
          else
            sprite = new SquareMaskSprite(@recordingMaskStyle)
            @addChild(sprite)
            @recordingMasks.push(sprite)

          sprite.x = x * Tile.WIDTH
          sprite.y = y * Tile.HEIGHT
          usedMasks += 1

    if usedMasks < @recordingMasks.length
      for i in [usedMasks..@recordingMasks.length - 1]
        @removeChild(@recordingMasks[i])

    @recordingMasks = @recordingMasks.slice(0, usedMasks)

    return unless extent

    # Add the handles
    for side in ['top', 'left', 'right', 'bottom']
      @recordingHandles[side] = new HandleSprite(side, extent)
      @recordingHandles[side].positionWithExtent(extent)
      @addChild(@recordingHandles[side])

    @centerOnRecordingRegion() if @recordingCentered



  setRecordingCentered: (centered) ->
    @recordingCentered = centered
    @centerOnRecordingRegion() if @recordingCentered
    @update()


  centerOnRecordingRegion: () ->
    if @recordingExtent
      @offsetTarget.x = (4.5 - @recordingExtent.left - (@recordingExtent.right - @recordingExtent.left) / 2) * Tile.WIDTH
      @offsetTarget.y = (4 - @recordingExtent.top - (@recordingExtent.bottom - @recordingExtent.top) / 2) * Tile.HEIGHT


  centerOnEntireCanvas: () ->
    @offsetTarget.x = @offsetTarget.y = 0


  update: (elapsed) ->
    @widthCurrent = @widthCurrent + (@widthTarget - @widthCurrent) / 15.0
    @canvas.width = Math.round(@widthCurrent) unless @canvas.width == Math.round(@widthCurrent)

    super

    for actor in @actors
      actor.tick(elapsed)

    @x += (@offsetTarget.x - @x) / 15
    @y += (@offsetTarget.y - @y) / 15


  wrappedPosition: (pos) ->
    pos.x = (pos.x + @width) % @width if @wrapX
    pos.y = (pos.y + @height) % @height if @wrapY
    pos

  # -- Managing Actors on the Stage -- #

  addActor: (descriptor, pointIfNotInDescriptor = null) ->
    actor = window.Game.library.instantiateActorFromDescriptor(descriptor, pointIfNotInDescriptor)
    return console.log('Could not read descriptor:', descriptor) if !actor

    actor.addEventListener 'click', (e) =>
      window.Game.onActorClicked(actor)
    actor.addEventListener 'dblclick', (e) =>
      window.Game.onActorDoubleClicked(actor)
    actor.stage = @
    actor.tick(0)

    @actors.push(actor)
    @addChild(actor)
    actor


  isDescriptorValid: (descriptor) ->
    @actorMatchingDescriptor(descriptor)?


  actorsAtPosition: (position) ->
    position = @wrappedPosition(position)
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

    # if the descriptor is empty and no actors are present, we've got a match
    return true if searchSet.length == 0 && (!descriptors || descriptors.length == 0)

    # if we don't have a descriptor for each item in the search set, no match
    return false if searchSet.length != descriptors.length

    # make sure the descriptors and actors all match
    for actor in searchSet
      matched = false
      for descriptor in descriptors
        matched = true if actor.matchesDescriptor(descriptor)
      return false unless matched

    true

  actorWithID: (id, set = @actors) ->
    for actor in set
      return actor if actor._id == id
    false


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