
KEYCODE_SPACE = 32
KEYCODE_UP = 38
KEYCODE_LEFT = 37
KEYCODE_RIGHT = 39
KEYCODE_W = 87
KEYCODE_A = 65
KEYCODE_D = 68


class GameManager
  statusCanvas = null
  statusCanvasCtx = null
  overlayEnabled = true

  constructor: (stage, gameWidth, gameHeight) ->
    @stage = stage
    @gameWidth = gameWidth
    @gameHeight = gameHeight
    @levelIndex = -1
    @level = null
    @wasContinuePressed = false
    @continuePressed = false
    @hudScoreLabel = null
    @hudFPSLabel = null

    document.onkeydown = (e) => @handleKeyDown(e)
    document.onkeyup = (e) => @handleKeyUp(e)
    @


  tick: ->
    try
      if @level isnt null
        @level.Update()
        @UpdateScore()

        # If the hero died or won, display the appropriate overlay
        @DrawOverlay()  if overlayEnabled
    catch e
      console.log "Error", e.message


  UpdateScore: ->
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

    @hudScoreLabel.text = "SCORE: " + @level.Score
    @hudFPSLabel.text = Math.round(Ticker.getMeasuredFPS()) + " fps"


  DrawOverlay: ->
    status = null
    if @level.TimeRemaining is 0
      if @level.ReachedExit
        status = window.Game.Content.imageNamed('you_win')
      else
        status = window.Game.Content.imageNamed('you_lose')
    else
      status = window.Game.Content.imageNamed('you_died') unless @level.Hero.IsAlive
    @ShowStatusCanvas(status) if status isnt null


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
    overlayEnabled = false


  # Hiding the overlay canvas while playing the game
  HideStatusCanvas: ->
    overlayEnabled = true
    statusCanvas.style.display = "none"


  # Loading the next level contained into /level/{x}.txt
  LoadNextLevel: ->
    @levelIndex = 1

    # Searching where we are currently hosted
    nextLevelUrl = window.location.href.replace("index.html", "") + "levels/" + @levelIndex + ".txt"
    try
      request = new XMLHttpRequest()
      request.open("GET", nextLevelUrl, true)
      request.onreadystatechange = => @OnLevelReady(request)
      request.send(null)

    catch e
      console.log('Probably an access denied if you try to run from the file:// context')


  # Callback method for the onreadystatechange event of XMLHttpRequest
  OnLevelReady: (eventResult) ->
    if eventResult.readyState is 4
      if (eventResult.status == 200)
        levelData = eventResult.responseText.replace(/[\n\r\t]/g, '')
        @HideStatusCanvas()
        @level.Dispose()  if @level?
        @level = new Level(@stage, levelData)
        @level.StartLevel()
      else
        console.log('Error', eventResult.statusText);


  handleKeyDown: (e) ->
    e = window.event  unless e
    switch e.keyCode
      when KEYCODE_A, KEYCODE_LEFT
        @level.Hero.direction = -1
      when KEYCODE_D, KEYCODE_RIGHT
        @level.Hero.direction = 1
      when KEYCODE_W
        @level.Hero.isJumping = true
        @continuePressed = true

  handleKeyUp: (e) ->
    e = window.event  unless e
    switch e.keyCode
      when KEYCODE_A, KEYCODE_LEFT, KEYCODE_D, KEYCODE_RIGHT
        @level.Hero.direction = 0
      when KEYCODE_W
        @continuePressed = false


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
    @LoadNextLevel()

    Ticker.addListener(@)
    Ticker.useRAF = false
    Ticker.setFPS(60)


window.GameManager = GameManager