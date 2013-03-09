
  # To display to current FPS

  # Used to build the background with 3 different layers

  # Index used to loop inside the 8 Audio elements stored into an array
  # Used to simulate multi-channels audio
  Level = (stage, contentManager, textLevel, gameWidth, gameHeight) ->
    @levelContentManager = contentManager
    @levelStage = stage
    @gameWidth = gameWidth
    @gameHeight = gameHeight

    # Entities in the level.
    @Hero = null
    @Gems = []
    @Enemies = []

    # Key locations in the level.
    @Start = null
    @Exit = new Point(-1, -1)
    @Score = 0
    @ReachedExit = false
    @IsHeroDied = false

    # You've got 120s to finish the level
    @TimeRemaining = 120

    # Saving when at what time you've started the level
    @InitialGameTime = Ticker.getTime()

    # Creating a random background based on the 3 layers available in 3 versions
    @CreateAndAddRandomBackground()

    # Building a matrix of characters that will be replaced by the level {x}.txt
    @textTiles = Array.matrix(15, 20, "|")

    # Physical structure of the level.
    @tiles = Array.matrix(15, 20, "|")
    @LoadTiles textLevel
    @

  fpsLabel = undefined
  backgroundSeqTile1 = undefined
  backgroundSeqTile2 = undefined
  backgroundSeqTile3 = undefined
  PointsPerSecond = 5
  globalTargetFPS = 17
  audioGemIndex = 0
  StaticTile = new Tile(null, Enum.TileCollision.Passable, 0, 0)

  #/ <summary>
  #/ Unloads the level content.
  #/ </summary>
  Level::Dispose = ->
    @levelStage.removeAllChildren()
    @levelStage.update()
    try
      @levelContentManager.globalMusic.pause()


  # Transforming the long single line of text into
  # a 2D array of characters
  Level::ParseLevelLines = (levelLine) ->
    i = 0

    while i < 15
      j = 0

      while j < 20
        @textTiles[i][j] = levelLine.charAt((i * 20) + j)
        j++
      i++


  #/ <summary>
  #/ Iterates over every tile in the structure file and loads its
  #/ appearance and behavior. This method also validates that the
  #/ file is well-formed with a player start point, exit, etc.
  #/ </summary>
  #/ <param name="fileStream">
  #/ A string containing the tile data.
  #/ </param>
  Level::LoadTiles = (fileStream) ->
    @ParseLevelLines fileStream

    # Loop over every tile position,
    i = 0

    while i < 15
      j = 0

      while j < 20
        @tiles[i][j] = @LoadTile(@textTiles[i][j], j, i)
        j++
      i++

    # Verify that the level has a beginning and an end.
    throw "A level must have a starting point."  unless @Hero?
    throw "A level must have an exit."  if @Exit.x is -1 and @Exit.y is -1


  #/ <summary>
  #/ Loads an individual tile's appearance and behavior.
  #/ </summary>
  #/ <param name="tileType">
  #/ The character loaded from the structure file which
  #/ indicates what should be loaded.
  #/ </param>
  #/ <param name="x">
  #/ The X location of this tile in tile space.
  #/ </param>
  #/ <param name="y">
  #/ The Y location of this tile in tile space.
  #/ </param>
  #/ <returns>The loaded tile.</returns>
  Level::LoadTile = (tileType, x, y) ->
    switch tileType

      # Blank space
      when "."
        return new Tile(null, Enum.TileCollision.Passable, x, y)

      # Exit
      when "X"
        return @LoadExitTile(x, y)

      # Gem
      when "G"
        return @LoadGemTile(x, y)

      # Floating platform
      when "-"
        return @LoadNamedTile("Platform", Enum.TileCollision.Platform, x, y)

      # Various enemies
      when "A"
        return @LoadEnemyTile(x, y, "MonsterA")
      when "B"
        return @LoadEnemyTile(x, y, "MonsterB")
      when "C"
        return @LoadEnemyTile(x, y, "MonsterC")
      when "D"
        return @LoadEnemyTile(x, y, "MonsterD")

      # Platform block
      when "~"
        return @LoadVarietyTile("BlockB", 2, Enum.TileCollision.Platform, x, y)

      # Passable block
      when ":"
        return @LoadVarietyTile("BlockB", 2, Enum.TileCollision.Passable, x, y)

      # Player 1 start point
      when "1"
        return @LoadStartTile(x, y)

      # Impassable block
      when "#"
        return @LoadVarietyTile("BlockA", 7, Enum.TileCollision.Impassable, x, y)


  #/ <summary>
  #/ Creates a new tile. The other tile loading methods typically chain to this
  #/ method after performing their special logic.
  #/ </summary>
  #/ <param name="collision">
  #/ The tile collision type for the new tile.
  #/ </param>
  #/ <returns>The new tile.</returns>
  Level::LoadNamedTile = (name, collision, x, y) ->
    switch name
      when "Platform"
        return new Tile(@levelContentManager.imgPlatform, collision, x, y)
      when "Exit"
        return new Tile(@levelContentManager.imgExit, collision, x, y)
      when "BlockA0"
        return new Tile(@levelContentManager.imgBlockA0, collision, x, y)
      when "BlockA1"
        return new Tile(@levelContentManager.imgBlockA1, collision, x, y)
      when "BlockA2"
        return new Tile(@levelContentManager.imgBlockA2, collision, x, y)
      when "BlockA3"
        return new Tile(@levelContentManager.imgBlockA3, collision, x, y)
      when "BlockA4"
        return new Tile(@levelContentManager.imgBlockA4, collision, x, y)
      when "BlockA5"
        return new Tile(@levelContentManager.imgBlockA5, collision, x, y)
      when "BlockA6"
        return new Tile(@levelContentManager.imgBlockA6, collision, x, y)
      when "BlockB0"
        return new Tile(@levelContentManager.imgBlockB0, collision, x, y)
      when "BlockB1"
        return new Tile(@levelContentManager.imgBlockB1, collision, x, y)


  #/ <summary>
  #/ Loads a tile with a random appearance.
  #/ </summary>
  #/ <param name="baseName">
  #/ The content name prefix for this group of tile variations. Tile groups are
  #/ name LikeThis0.png and LikeThis1.png and LikeThis2.png.
  #/ </param>
  #/ <param name="variationCount">
  #/ The number of variations in this group.
  #/ </param>
  Level::LoadVarietyTile = (baseName, variationCount, collision, x, y) ->
    index = Math.floor(Math.random() * (variationCount - 1))
    @LoadNamedTile baseName + index, collision, x, y


  #/ <summary>
  #/ Instantiates a player, puts him in the level, and remembers where to put him when he is resurrected.
  #/ </summary>
  Level::LoadStartTile = (x, y) ->
    throw "A level may only have one starting point."  if @Hero?
    @Start = @GetBounds(x, y).GetBottomCenter()
    @Hero = new Player(@levelContentManager.imgPlayer, this, @Start)
    new Tile(null, Enum.TileCollision.Passable, x, y)


  #/ <summary>
  #/ Remembers the location of the level's exit.
  #/ </summary>
  Level::LoadExitTile = (x, y) ->
    throw "A level may only have one exit."  if @Exit.x isnt -1 & @Exit.y isnt y
    @Exit = @GetBounds(x, y).Center
    @LoadNamedTile "Exit", Enum.TileCollision.Passable, x, y


  #/ <summary>
  #/ Instantiates a gem and puts it in the level.
  #/ </summary>
  Level::LoadGemTile = (x, y) ->
    position = @GetBounds(x, y).Center
    position = new Point(x, y)
    @Gems.push new Gem(@levelContentManager.imgGem, this, position)
    new Tile(null, Enum.TileCollision.Passable, x, y)


  #/ <summary>
  #/ Instantiates an enemy and puts him in the level.
  #/ </summary>
  Level::LoadEnemyTile = (x, y, name) ->
    position = @GetBounds(x, y).GetBottomCenter()
    switch name
      when "MonsterA"
        @Enemies.push new Enemy(this, position, @levelContentManager.imgMonsterA)
      when "MonsterB"
        @Enemies.push new Enemy(this, position, @levelContentManager.imgMonsterB)
      when "MonsterC"
        @Enemies.push new Enemy(this, position, @levelContentManager.imgMonsterC)
      when "MonsterD"
        @Enemies.push new Enemy(this, position, @levelContentManager.imgMonsterD)
    new Tile(null, Enum.TileCollision.Passable, x, y)


  #/ <summary>
  #/ Gets the bounding rectangle of a tile in world space.
  #/ </summary>
  Level::GetBounds = (x, y) ->
    new XNARectangle(x * StaticTile.Width, y * StaticTile.Height, StaticTile.Width, StaticTile.Height)

  #/ <summary>
  #/ Width of level measured in tiles.
  #/ </summary>
  Level::Width = ->
    20


  #/ <summary>
  #/ Height of the level measured in tiles.
  #/ </summary>
  Level::Height = ->
    15


  #/ <summary>
  #/ Gets the collision mode of the tile at a particular location.
  #/ This method handles tiles outside of the levels boundries by making it
  #/ impossible to escape past the left or right edges, but allowing things
  #/ to jump beyond the top of the level and fall off the bottom.
  #/ </summary>
  Level::GetCollision = (x, y) ->

    # Prevent escaping past the level ends.
    return Enum.TileCollision.Impassable  if x < 0 or x >= @Width()

    # Allow jumping past the level top and falling through the bottom.
    return Enum.TileCollision.Passable  if y < 0 or y >= @Height()
    @tiles[y][x].Collision


  # Create a random background based on
  # the 3 different layers available
  Level::CreateAndAddRandomBackground = ->

    # random number between 0 & 2.
    randomnumber = Math.floor(Math.random() * 3)
    backgroundSeqTile1 = new Bitmap(@levelContentManager.imgBackgroundLayers[0][randomnumber])
    backgroundSeqTile2 = new Bitmap(@levelContentManager.imgBackgroundLayers[1][randomnumber])
    backgroundSeqTile3 = new Bitmap(@levelContentManager.imgBackgroundLayers[2][randomnumber])
    @levelStage.addChild backgroundSeqTile1
    @levelStage.addChild backgroundSeqTile2
    @levelStage.addChild backgroundSeqTile3


  # Method to call once everything has been setup in the level
  # to simply start it
  Level::StartLevel = ->

    # Adding all tiles to the EaselJS Stage object
    # This is the platform tile where the hero & enemies will
    # be able to walk onto
    i = 0

    while i < 15
      j = 0

      while j < 20
        @levelStage.addChild @tiles[i][j]  if !!@tiles[i][j] and not @tiles[i][j].empty
        j++
      i++

    # Adding the gems to the stage
    i = 0

    while i < @Gems.length
      @levelStage.addChild @Gems[i]
      i++

    # Adding all the enemies to the stage
    i = 0

    while i < @Enemies.length
      @levelStage.addChild @Enemies[i]
      i++

    # Adding our brillant hero
    @levelStage.addChild @Hero

    # Playing the background music
    @levelContentManager.globalMusic.play()

    # add a text object to output the current FPS:
    fpsLabel = new Text("-- fps", "bold 14px Arial", "#000")
    @levelStage.addChild fpsLabel
    fpsLabel.x = @gameWidth - 50
    fpsLabel.y = 20


  #/ <summary>
  #/ Updates all objects in the world, performs collision between them,
  #/ and handles the time limit with scoring.
  #/ </summary>
  Level::Update = ->
    ElapsedGameTime = (Ticker.getTime() - @InitialGameTime) / 1000
    @Hero.tick()
    if not @Hero.IsAlive or @TimeRemaining is 0
      @Hero.ApplyPhysics()
    else if @ReachedExit
      seconds = parseInt((globalTargetFPS / 1000) * 200)
      seconds = Math.min(seconds, parseInt(Math.ceil(@TimeRemaining)))
      @TimeRemaining -= seconds
      @Score += seconds * PointsPerSecond
    else
      @TimeRemaining = 120 - ElapsedGameTime
      @UpdateGems()  unless @IsHeroDied
      @OnPlayerKilled()  if @Hero.BoundingRectangle().Top() >= @Height() * StaticTile.Height
      @UpdateEnemies()

      # The player has reached the exit if they are standing on the ground and
      # his bounding rectangle contains the center of the exit tile. They can only
      # exit when they have collected all of the gems.
      @OnExitReached()  if @Hero.IsAlive and @Hero.IsOnGround and @Hero.BoundingRectangle().ContainsPoint(@Exit)

    # Clamp the time remaining at zero.
    @TimeRemaining = 0  if @TimeRemaining < 0
    fpsLabel.text = Math.round(Ticker.getMeasuredFPS()) + " fps"

    # update the stage:
    @levelStage.update()


  #/ <summary>
  #/ Animates each gem and checks to allows the player to collect them.
  #/ </summary>
  Level::UpdateGems = ->
    i = 0

    while i < @Gems.length
      @Gems[i].tick()
      if @Gems[i].BoundingRectangle().Intersects(@Hero.BoundingRectangle())

        # We remove it from the drawing surface
        @levelStage.removeChild @Gems[i]
        @Score += @Gems[i].PointValue

        # We then remove it from the in memory array
        @Gems.splice i, 1

        # And we finally play the gem collected sound using a multichannels trick
        @levelContentManager.gemCollected[audioGemIndex % 8].play()
        audioGemIndex++
      i++


  #/ <summary>
  #/ Animates each enemy and allow them to kill the player.
  #/ </summary>
  Level::UpdateEnemies = ->
    i = 0

    while i < @Enemies.length
      if @Hero.IsAlive and @Enemies[i].BoundingRectangle().Intersects(@Hero.BoundingRectangle())
        @OnPlayerKilled @Enemies[i]

        # Forcing a complete rescan of the Enemies Array to update them that the hero is dead
        i = 0
      @Enemies[i].tick()
      i++


  #/ <summary>
  #/ Called when the player is killed.
  #/ </summary>
  #/ <param name="killedBy">
  #/ The enemy who killed the player. This is null if the player was not killed by an
  #/ enemy, such as when a player falls into a hole.
  #/ </param>
  Level::OnPlayerKilled = (killedBy) ->
    @IsHeroDied = true
    @Hero.OnKilled killedBy


  #/ <summary>
  #/ Called when the player reaches the level's exit.
  #/ </summary>
  Level::OnExitReached = ->
    @Hero.OnReachedExit()
    @ReachedExit = true

  Level::StartNewLife = ->
    @Hero.Reset @Start

  window.Level = Level
