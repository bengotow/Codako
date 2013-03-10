
class GameManager

  statusCanvas = null
  statusCanvasCtx = null

  constructor: (stage, gameWidth, gameHeight) ->
    @stage = stage
    @gameWidth = gameWidth
    @gameHeight = gameHeight
    @level = null
    @wasContinuePressed = false
    @continuePressed = false
    @hudScoreLabel = null
    @hudFPSLabel = null
    @

  tick: ->
    try
      if @level isnt null
        @level.update()
        @updateScore()
    catch e
      console.log "Error", e.message


  updateScore: ->
    if @hudScoreLabel is null
      @hudScoreLabel = new Text("SCORE: 0", "bold 14px Arial", "yellow")
      @hudScoreLabel.x = 10
      @hudScoreLabel.y = 34
      @stage.addChild(@hudScoreLabel)

    if @hudFPSLabel is null
      @hudFPSLabel = new Text("-- fps", "bold 14px Arial", "#000")
      @hudFPSLabel.x = @gameWidth - 50
      @hudFPSLabel.y = 20
      @stage.addChild(@hudFPSLabel)

    @hudScoreLabel.text = "SCORE: None"
    @hudFPSLabel.text = Math.round(Ticker.getMeasuredFPS()) + " fps"


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


    Ticker.addListener(@)
    Ticker.useRAF = false
    Ticker.setFPS(60)


window.GameManager = GameManager