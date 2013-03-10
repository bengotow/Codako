
class Level
  @defaultJSON:
    width: 20
    height: 15
    actor_descriptors: [
      {
        identifier: 'dude',
        position: {x: 10, y: 10}
      },
      {
        identifier: 'rock',
        position: {x: 7, y: 10}
      }

    ]


  constructor: (stage, identifier = 'untitled') ->
    @identifier = identifier
    @stage = stage
    @actors = []

    @ruleCheckInterval = 0.5
    @ruleCheckNextElapsed = 0
    @elapsed = 0

    @keysDown = {}
    @keysUpSinceLast = {}
    document.onkeydown = (e) =>
      @keysDown[e.keyCode] = true
    document.onkeyup = (e) =>
      @keysUpSinceLast[e.keyCode] = true

    # Creating a random background based on the 3 layers available in 3 versions
    @stage.addChild(new Bitmap(window.Game.Content.imageNamed('Layer0_0')))
    @

  #/ <summary>
  #/ Gets the bounding rectangle of a tile in world space.
  #/ </summary>
  getBounds: (x, y) ->
    new XNARectangle(x * Tile.WIDTH, y * Tile.HEIGHT, Tile.WIDTH, Tile.HEIGHT)


  dispose: ->
    @stage.removeAllChildren()
    @stage.update()
    try
      window.Game.Content.pauseSound('globalMusic')


  load: (callback) ->
    url = window.location.href.replace("index.html", "") + "levels/#{@identifier}.txt"
    try
      request = new XMLHttpRequest()
      request.open("GET", url, true)
      request.onreadystatechange = =>
        if request.readyState is 4
          if (request.status == 200)
            @loadDataReady(JSON.parse(request.responseText))
          else
            console.log('Error', request.statusText)
            @loadDataReady(Level.defaultJSON)
          callback(null)
      request.send(null)

    catch e
      console.log('Probably an access denied if you try to run from the file:// context')


  # Callback method for the onreadystatechange event of XMLHttpRequest
  loadDataReady: (json) ->
    @width = json['width']
    @height = json['height']
    @tiles = Array.matrix(@height, @width, "|")
    @initialGameTime = Ticker.getTime()

    for descriptor in json['actor_descriptors']
      actor = window.Game.Library.instantiateActorFromDescriptor(descriptor, @)
      if !actor
        console.log('Could not read descriptor:', descriptor)
        continue
      @actors.push(actor)
      @stage.addChild(actor)

    # Playing the background music
    window.Game.Content.playSound('Music')


  isKeyDown: (code) ->
    return @keysDown[code]

  applyLiftedKeys: () ->
    for code, value of @keysUpSinceLast
        delete @keysDown[code]
    @keysUpSinceLast = {}


  isDescriptorValid: (descriptor) ->
    actorMatchingDescriptor(descriptor)?


  actorsAtPosition: (position) ->
    results = []
    for actor in @actors
      if actor.worldPos.x == position.x && actor.worldPos.y == position.y
        results.push(actor)
    results


  actorsAtPositionMatchDescriptors: (position, descriptors) ->
    searchSet = @actorsAtPosition(position)

    return searchSet.length == 0 if !descriptors

    for actor in searchSet
      matched = false
      for descriptor in descriptors
        matched = true if window.Game.Library.actorMatchesDescriptor(actor, descriptor)
      return false unless matched

    true

  actorMatchingDescriptor: (position, descriptor) ->
    for actor in @actors
      return actor if window.Game.Library.actorMatchesDescriptor(actor, descriptor)
    false

  #/ <summary>
  #/ Updates all objects in the world, performs collision between them,
  #/ and handles the time limit with scoring.
  #/ </summary>
  update: ->
    elapsed = (Ticker.getTime() - @initialGameTime) / 1000

    for actor in @actors
      actor.tick(elapsed)

    if elapsed > @ruleCheckNextElapsed
      console.log 'Testing Rules'
      @ruleCheckNextElapsed += @ruleCheckInterval
      for actor in @actors
        actor.applyRules()
      @applyLiftedKeys()

    @stage.update()


  window.Level = Level
