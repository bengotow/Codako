
class GameManager

  statusCanvas = null
  statusCanvasCtx = null

  constructor: (stage, renderingStage, gameWidth, gameHeight) ->
    @stage = stage
    @renderingStage = renderingStage

    @gameWidth = gameWidth
    @gameHeight = gameHeight
    @level = null
    @wasContinuePressed = false
    @continuePressed = false
    @


  tick: ->
    try
      if @level isnt null
        @level.update()
        @hud.update()
    catch e
      console.log "Error", e.message


  # Creating a second canvas to display it over the main gaming canvas
  # It's displayed in style:absolute
  # It is used to display to proper overlay contained in /overlays folder
  # with some opacity effect
  SetOverlayCanvas: ->
    oneOfThisOverlay = window.Game.Content.imageNamed('you_win')
    statusCanvas = document.createElement("canvas")
    document.body.appendChild statusCanvas
    statusCanvasCtx = statusCanvas.getContext("2d")
    statusCanvas.setAttribute "width", oneOfThisOverlay.width
    statusCanvas.setAttribute "height", oneOfThisOverlay.height

    # We center it
    statusX = (@gameWidth - oneOfThisOverlay.width) / 2
    statusY = (@gameHeight - oneOfThisOverlay.height) / 2
    statusCanvas.style.position = "absolute"
    statusCanvas.style.top = statusY + "px"
    statusCanvas.style.left = statusX + "px"


  # Cleaning the previous overlay canvas and setting it visible
  # with the new overlay image
  ShowStatusCanvas: (status) ->
    statusCanvas.style.display = "block"
    statusCanvasCtx.clearRect 0, 0, status.width, status.height
    statusCanvasCtx.drawImage status, 0, 0


  # Hiding the overlay canvas while playing the game
  HideStatusCanvas: ->
    statusCanvas.style.display = "none"


  contentStatusChanged: (state) =>
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
      @contentStatusReady()


  contentStatusReady: () ->
    # Preparing the overlay canvas for future usage
    @SetOverlayCanvas()

    @level.dispose()  if @level?
    @level = new Level(@stage, 'untitled')
    @level.load () =>
      @HideStatusCanvas()

    @hud = new LibraryHUD(@stage)

    Ticker.addListener(@)
    Ticker.useRAF = false
    Ticker.setFPS(60)


  libraryActorsLoaded: () ->
    @hud.reload() if @hud


  renderRuleScenario: (scenario, applyActions = false) ->
    # Creating a random background based on the 3 layers available in 3 versions
    @renderingStage.addChild(new Bitmap(window.Game.Content.imageNamed('Layer0_0')))

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
        actor = window.Game.Library.instantiateActorFromDescriptor(descriptor)
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