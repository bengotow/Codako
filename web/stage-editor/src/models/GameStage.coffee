class GameStage extends Stage

  constructor: (canvas) ->
    GameStage.__super__.initialize.call(this, canvas)
    @_id = null

    @background = null
    @backgroundSprite = null

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

    @startDescriptors = null

    @widthTarget = canvas.width
    @widthCurrent = canvas.width

    @canvas.ondrop = (e, dragEl) =>
      dragIdentifier = $(dragEl.draggable).data('identifier')
      parentOffset = $(@canvas).parent().offset()

      # account for the stage's transform
      e.pageX = e.pageX - @x - $(_this.canvas).offset().left
      e.pageY = e.pageY - @y

      # compute grid point
      point = new Point(Math.round((e.pageX - e.offsetX) / Tile.WIDTH), Math.round((e.pageY - e.offsetY - parentOffset.top) / Tile.HEIGHT))

      if dragIdentifier[0..4] == 'actor'
        actor = @addActor({definition_id: dragIdentifier[6..-1], position: point})
        window.Game.onActorPlaced(actor, @)

      else if dragIdentifier[0..9] == 'appearance'
        actor = @actorsAtPosition(point)[0]
        window.Game.onAppearancePlaced(actor, @, dragIdentifier[11..-1]) if actor


  onscreen: () ->
    @widthTarget > 1 || @widthCurrent > 1


  setDisplayWidth: (width) ->
    @widthTarget = width


  saveData: (options = {}) ->
    data =
      _id: @_id
      width: @width,
      height: @height,
      wrapX: @wrapX,
      wrapY: @wrapY,
      background: @background,
      actor_library: window.Game.library.actorDefinitionIDs(),
      actor_descriptors: [],
      start_descriptors: @startDescriptors,
      start_thumbnail: @startThumbnail

    data.thumbnail = @canvas.toDataURL("image/jpeg", 0.8) if options.thumbnail
    data.actor_descriptors.push(actor.descriptor()) for actor in @actors
    data


  prepareWithData: (json, callback) ->
    @dispose()

    @width = json['width']
    @height = json['height']
    @wrapX = json['wrapX']
    @wrapY = json['wrapY']
    @startDescriptors = json['start_descriptors']
    @startThumbnail = json['start_thumbnail']

    @setBackground(json['background'])

    # make sure all of the actors on the stage are in the library
    library = json.actor_library || []
    for actor in json.actor_descriptors
      library.push(actor.definition_id) if library.indexOf(actor.definition_id) == -1

    # fetch the actor definitions (which include base64 image data, etc...)
    window.Game.library.loadActorDefinitions library, (err) =>
      @addActor(descriptor) for descriptor in json.actor_descriptors
      @update()
      callback(null) if callback


  setStartState: () =>
    @startDescriptors = []
    @startDescriptors.push(actor.descriptor()) for actor in @actors

    @cache(0, 0, @canvas.width, @canvas.height, 0.1)
    @startThumbnail = @cacheCanvas.toDataURL("image/jpg", 0.5)
    @uncache()


  resetToStartState: () =>
    @actors = []
    data = @saveData()
    data.actor_descriptors = [].concat(data.start_descriptors)
    @prepareWithData(data)


  dispose: () =>
    @actors = []
    @recordingMasks = []
    @recordingHandles = {}
    @removeAllChildren()
    @update()


  setBackground: (background, animate = false) =>
    @background = background || '/stage-editor/img/backgrounds/Layer0_2.png'

    img = new Image()
    img.crossOrigin = 'Anonymous'
    img.src = ''
    $(img).on 'load', () =>
      $(img).off 'load'
      @removeChild(@backgroundSprite) if @backgroundSprite

      @backgroundSprite = new Bitmap(img)

      scale = Math.max((@width * Tile.WIDTH) / img.width, (@height * Tile.HEIGHT) / img.height)
      @backgroundSprite.scaleX = @backgroundSprite.scaleY = scale

      @backgroundSprite.addEventListener 'click', (e) =>
        window.Game.onActorClicked(null)
      @backgroundSprite.addEventListener 'dblclick', (e) =>
        window.Game.onActorDoubleClicked(null)
      @addChildAt(@backgroundSprite, 0)

    if @background.indexOf('/') != -1
      img.src = @background
    else
      img.src = "//cocoa-user-assets.s3-website-us-east-1.amazonaws.com/#{@background}"


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


  clearRecording: () ->
    @setRecordingCentered(false)
    @setRecordingExtent(null)
    @centerOnEntireCanvas()
    @draggingEnabled = true


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
    return null if position.x < 0 || position.y < 0 || position.x >= @width || position.y >= @height

    results = []
    for actor in @actors
      if actor.worldPos.isEqual(position)
        results.push(actor)
    results


  actorsAtPositionMatchDescriptors: (position, descriptors) ->
    searchSet = @actorsAtPosition(position)
    return false if searchSet == null

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
    results = []
    for actor in set
      results.push(actor) if actor._id == id

    if results.length > 1
      console.log "There are multiple actors with the same ID!", results
    results[0]


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