#usefull keycodes

# The number of levels in the Levels directory of our content. We assume that
# levels in our content are 0-based and that all numbers under this constant
# have a level file present. This allows us to not need to check for the file
# or handle exceptions, both of which can add unnecessary time to level loading.

# Used in case of an HTTP issue or access denied on file://
# This is a static level. So if you're looping always on the same level
# You're stuck in the Matrix because of an exception somewhere... Up to you to find where!

# Variables used to handle the overlay canvas to display "You died", "You win", etc.

# Displaying the timer in red under 30s of remaining time
PlatformerGame = (stage, contentManager, gameWidth, gameHeight) ->
  @platformerGameStage = stage
  @platformerGameContentManager = contentManager
  @gameWidth = gameWidth
  @gameHeight = gameHeight
  @levelIndex = -1
  @level = null
  @wasContinuePressed = false
  @continuePressed = false

  # Preparing the overlay canvas for future usage
  @SetOverlayCanvas()

  # Little closure needed here
  instance = this # store the current context

  # Our hero can be moved with the arrow keys (left, right)
  # And jump with W
  document.onkeydown = (e) ->
    instance.handleKeyDown(e)

  document.onkeyup = (e) ->
    instance.handleKeyUp(e)

  @LoadNextLevel()


KEYCODE_SPACE = 32
KEYCODE_UP = 38
KEYCODE_LEFT = 37
KEYCODE_RIGHT = 39
KEYCODE_W = 87
KEYCODE_A = 65
KEYCODE_D = 68

numberOfLevels = 4
hardcodedErrorTextLevel = ".....................................................................................................................................................GGG.................###................................GGG.......GGG.......###...--..###........................1................X.####################"
statusCanvas = null
statusCanvasCtx = null
overlayEnabled = true
scoreText = null
timeRemainingText = null
WarningTime = 30

# Update logic callbacked by EaselJS
# Equivalent of the Update() method of XNA
PlatformerGame::tick = ->
  try
    if @level isnt null
      @HandleInput()
      @level.Update()
      @UpdateScore()

      # If the hero died or won, display the appropriate overlay
      @DrawOverlay()  if overlayEnabled
  catch e
    console.log "Error", e


# Starting the game
PlatformerGame::StartGame = ->

  # we want to do some work before we update the canvas,
  # otherwise we could use Ticker.addListener(stage);
  Ticker.addListener(this)

  # Targeting 60 FPS
  Ticker.useRAF = enableRAF
  Ticker.setFPS 60


# Well, the method's name should be self explicit ;-)
PlatformerGame::UpdateScore = ->
  if scoreText is null
    timeRemainingText = new Text("TIME: ", "bold 14px Arial", "yellow")
    timeRemainingText.x = 10
    timeRemainingText.y = 20
    @platformerGameStage.addChild timeRemainingText

    scoreText = new Text("SCORE: 0", "bold 14px Arial", "yellow")
    scoreText.x = 10
    scoreText.y = 34
    @platformerGameStage.addChild scoreText

  if @level.TimeRemaining < WarningTime and not @level.ReachedExit
    timeRemainingText.color = "red"
  else
    timeRemainingText.color = "yellow"
  scoreText.text = "SCORE: " + @level.Score
  timeRemainingText.text = "TIME: " + parseInt(@level.TimeRemaining)


# Perform the appropriate action to advance the game and
# to get the player back to playing.
PlatformerGame::HandleInput = ->
  if not @wasContinuePressed and @continuePressed
    unless @level.Hero.IsAlive
      @HideStatusCanvas()
      @level.StartNewLife()
    else if @level.TimeRemaining is 0
      if @level.ReachedExit
        @LoadNextLevel()
      else
        @ReloadCurrentLevel()
  @wasContinuePressed = @continuePressed


# Determine the status overlay message to show.
PlatformerGame::DrawOverlay = ->
  status = null
  if @level.TimeRemaining is 0
    if @level.ReachedExit
      status = @platformerGameContentManager.winOverlay
    else
      status = @platformerGameContentManager.loseOverlay
  else status = @platformerGameContentManager.diedOverlay  unless @level.Hero.IsAlive
  @ShowStatusCanvas status  if status isnt null


# Creating a second canvas to display it over the main gaming canvas
# It's displayed in style:absolute
# It is used to display to proper overlay contained in /overlays folder
# with some opacity effect
PlatformerGame::SetOverlayCanvas = ->
  oneOfThisOverlay = @platformerGameContentManager.winOverlay
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
PlatformerGame::ShowStatusCanvas = (status) ->
  statusCanvas.style.display = "block"
  statusCanvasCtx.clearRect 0, 0, status.width, status.height
  statusCanvasCtx.drawImage status, 0, 0
  overlayEnabled = false


# Hiding the overlay canvas while playing the game
PlatformerGame::HideStatusCanvas = ->
  overlayEnabled = true
  statusCanvas.style.display = "none"


# Loading the next level contained into /level/{x}.txt
PlatformerGame::LoadNextLevel = ->
  @levelIndex = (@levelIndex + 1) % numberOfLevels

  # Searching where we are currently hosted
  nextLevelUrl = window.location.href.replace("index.html", "") + "levels/" + @levelIndex + ".txt"
  try
    request = new XMLHttpRequest()
    request.open("GET", nextLevelUrl, true)

    # Little closure
    instance = this
    request.onreadystatechange = ->
      instance.OnLevelReady(this)

    request.send(null)

  catch e
    # Probably an access denied if you try to run from the file:// context
    # Loading the hard coded error level to have at least something to play with
    @LoadThisTextLevel hardcodedErrorTextLevel


# Callback method for the onreadystatechange event of XMLHttpRequest
PlatformerGame::OnLevelReady = (eventResult) ->
  newTextLevel = ""
  if eventResult.readyState is 4

    # If everything was OK
    if (eventResult.status == 200)
      newTextLevel = eventResult.responseText.replace(/[\n\r\t]/g, '')
    else
      console.log('Error', eventResult.statusText);
      # Loading a hard coded level in case of error
      newTextLevel = hardcodedErrorTextLevel;

    @LoadThisTextLevel newTextLevel

PlatformerGame::LoadThisTextLevel = (textLevel) ->
  @HideStatusCanvas()
  scoreText = null

  # Unloads the content for the current level before loading the next one.
  @level.Dispose()  if @level?
  @level = new Level(@platformerGameStage, @platformerGameContentManager, textLevel, @gameWidth, @gameHeight)
  @level.StartLevel()


# Loaded if the hero lost because of a timeout
PlatformerGame::ReloadCurrentLevel = ->
  --@levelIndex
  @LoadNextLevel()

PlatformerGame::handleKeyDown = (e) ->
  e = window.event  unless e
  switch e.keyCode
    when KEYCODE_A, KEYCODE_LEFT
      @level.Hero.direction = -1
    when KEYCODE_D, KEYCODE_RIGHT
      @level.Hero.direction = 1
    when KEYCODE_W
      @level.Hero.isJumping = true
      @continuePressed = true

PlatformerGame::handleKeyUp = (e) ->
  e = window.event  unless e
  switch e.keyCode
    when KEYCODE_A, KEYCODE_LEFT, KEYCODE_D, KEYCODE_RIGHT
      @level.Hero.direction = 0
    when KEYCODE_W
      @continuePressed = false

window.PlatformerGame = PlatformerGame