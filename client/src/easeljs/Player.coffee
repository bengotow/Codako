class Player extends BitmapAnimation

  MoveAcceleration = 13000.0
  MaxMoveSpeed = 1750.0
  GroundDragFactor = 0.48
  AirDragFactor = 0.58
  MaxJumpTime = 0.35
  JumpLaunchVelocity = -5000.0
  GravityAcceleration = 1800.0
  MaxFallSpeed = 550.0
  JumpControlPower = 0.14
  globalTargetFPS = 17
  StaticTile = new Tile(null, Enum.TileCollision.Passable, 0, 0)



  constructor: (imgPlayer, level, position) ->
    @localSpriteSheet = new SpriteSheet(
      images: [imgPlayer] #image to use
      frames:
        width: 64
        height: 64
        regX: 32
        regY: 64

      animations:
        walk: [0, 9, "walk", 4]
        die: [10, 21, false, 4]
        jump: [22, 32, false]
        celebrate: [33, 43, false, 4]
        idle: [44, 44]
    )
    SpriteSheetUtils.addFlippedFrames(@localSpriteSheet, true, false, false)
    Player.__super__.initialize(@localSpriteSheet)

    @level = level
    @position = position
    @velocity = new Point(0, 0)
    @previousBottom = 0.0
    @elapsed = 0
    @isJumping = false
    @wasJumping = false
    @jumpTime = 0.0
    @frameWidth = @spriteSheet.getFrame(0).rect.width
    @frameHeight = @spriteSheet.getFrame(0).rect.height
    @IsAlive = true
    @HasReachedExit = false
    @IsOnGround = true

    # Calculate bounds within texture size.
    @width = parseInt(@frameWidth * 0.4)
    @left = parseInt((@frameWidth - @width) / 2)
    @height = parseInt(@frameWidth * 0.8)
    @top = parseInt(@frameHeight - @height)
    @localBounds = new XNARectangle(@left, @top, @width, @height)

    # set up a shadow. Note that shadows are ridiculously expensive. You could display hundreds
    # of animated monster if you disabled the shadow.
    @name = "Hero"

    # 1 = right & -1 = left & 0 = idle
    @direction = 0

    # starting directly at the first frame of the walk_right sequence
    @currentFrame = 66
    @Reset(position)
    @



  #/ <summary>
  #/ Resets the player to life.
  #/ </summary>
  #/ <param name="position">The position to come to life at.</param>
  Reset: (position) ->
    @x = position.x
    @y = position.y
    @velocity = new Point(0, 0)
    @IsAlive = true
    @level.IsHeroDied = false
    @gotoAndPlay "idle"


  #/ <summary>
  #/ Gets a rectangle which bounds this player in world space.
  #/ </summary>
  BoundingRectangle: ->
    left = parseInt(Math.round(@x - 32) + @localBounds.x)
    top = parseInt(Math.round(@y - 64) + @localBounds.y)
    new XNARectangle(left, top, @localBounds.width, @localBounds.height)


  #/ <summary>
  #/ Handles input, performs physics, and animates the player sprite.
  #/ </summary>
  #/ <remarks>
  #/ We pass in all of the input states so that our game is only polling the hardware
  #/ once per frame. We also pass the game's orientation because when using the accelerometer,
  #/ we need to reverse our motion when the orientation is in the LandscapeRight orientation.
  #/ </remarks>
  tick: ->

    # It not possible to have a predictable tick/update time
    # requestAnimationFrame could help but is currently not widely and properly supported by browsers
    # this.elapsed = (Ticker.getTime() - this.lastUpdate) / 1000;
    # We're then forcing/simulating a perfect world
    @elapsed = globalTargetFPS / 1000
    @ApplyPhysics()
    if @IsAlive and @IsOnGround and not @HasReachedExit
      if Math.abs(@velocity.x) - 0.02 > 0

        # Checking if we're not already playing the animation
        @gotoAndPlay "walk"  if @currentAnimation.indexOf("walk") is -1 and @direction is -1
        @gotoAndPlay "walk_h"  if @currentAnimation.indexOf("walk_h") is -1 and @direction is 1
      else
        @gotoAndPlay "idle"  if @currentAnimation.indexOf("idle") is -1 and @direction is 0

    # Clear input.
    @isJumping = false


  #/ <summary>
  #/ Updates the player's velocity and position based on input, gravity, etc.
  #/ </summary>
  ApplyPhysics: ->
    if @IsAlive and not @HasReachedExit
      previousPosition = new Point(@x, @y)

      # Base velocity is a combination of horizontal movement control and
      # acceleration downward due to gravity.
      @velocity.x += @direction * MoveAcceleration * @elapsed
      @velocity.y = Math.clamp(@velocity.y + GravityAcceleration * @elapsed, -MaxFallSpeed, MaxFallSpeed)
      @velocity.y = @DoJump(@velocity.y)

      # Apply pseudo-drag horizontally.
      if @IsOnGround
        @velocity.x *= GroundDragFactor
      else
        @velocity.x *= AirDragFactor

      # Prevent the player from running faster than his top speed.
      @velocity.x = Math.clamp(@velocity.x, -MaxMoveSpeed, MaxMoveSpeed)
      @x += @velocity.x * @elapsed
      @y += @velocity.y * @elapsed
      @x = Math.round(@x)
      @y = Math.round(@y)

      # If the player is now colliding with the level, separate them.
      @HandleCollisions()

      # If the collision stopped us from moving, reset the velocity to zero.
      @velocity.x = 0  if @x is previousPosition.x
      @velocity.y = 0  if @y is previousPosition.y


  #/ <summary>
  #/ Calculates the Y velocity accounting for jumping and
  #/ animates accordingly.
  #/ </summary>
  #/ <remarks>
  #/ During the accent of a jump, the Y velocity is completely
  #/ overridden by a power curve. During the decent, gravity takes
  #/ over. The jump velocity is controlled by the jumpTime field
  #/ which measures time into the accent of the current jump.
  #/ </remarks>
  #/ <param name="velocityY">
  #/ The player's current velocity along the Y axis.
  #/ </param>
  #/ <returns>
  #/ A new Y velocity if beginning or continuing a jump.
  #/ Otherwise, the existing Y velocity.
  #/ </returns>
  DoJump: (velocityY) ->

    # If the player wants to jump
    if @isJumping

      # Begin or continue a jump
      if (not @wasJumping and @IsOnGround) or @jumpTime > 0.0
        window.Game.Content.playSound('PlayerJump') if @jumpTime is 0.0
        @jumpTime += @elapsed

        # Playing the proper animation based on
        # the current direction of our hero
        if @direction is 1
          @gotoAndPlay "jump_h"
        else
          @gotoAndPlay "jump"

      # If we are in the ascent of the jump
      if 0.0 < @jumpTime and @jumpTime <= MaxJumpTime

        # Fully override the vertical velocity with a power curve that gives players more control over the top of the jump
        velocityY = JumpLaunchVelocity * (1.0 - Math.pow(@jumpTime / MaxJumpTime, JumpControlPower))
      else

        # Reached the apex of the jump
        @jumpTime = 0.0
    else

      # Continues not jumping or cancels a jump in progress
      @jumpTime = 0.0
    @wasJumping = @isJumping
    velocityY


  #/ <summary>
  #/ Detects and resolves all collisions between the player and his neighboring
  #/ tiles. When a collision is detected, the player is pushed away along one
  #/ axis to prevent overlapping. There is some special logic for the Y axis to
  #/ handle platforms which behave differently depending on direction of movement.
  #/ </summary>
  HandleCollisions: ->
    bounds = @BoundingRectangle()
    leftTile = Math.floor(bounds.left() / StaticTile.Width)
    rightTile = Math.ceil((bounds.right() / StaticTile.Width)) - 1
    topTile = Math.floor(bounds.top() / StaticTile.Height)
    bottomTile = Math.ceil((bounds.bottom() / StaticTile.Height)) - 1

    # Reset flag to search for ground collision.
    @IsOnGround = false

    # For each potentially colliding tile,
    y = topTile

    while y <= bottomTile
      x = leftTile

      while x <= rightTile

        # If this tile is collidable,
        collision = @level.GetCollision(x, y)
        if collision isnt Enum.TileCollision.Passable

          # Determine collision depth (with direction) and magnitude.
          tileBounds = @level.GetBounds(x, y)
          depth = bounds.getIntersectionDepth(tileBounds)
          if depth.x isnt 0 and depth.y isnt 0
            absDepthX = Math.abs(depth.x)
            absDepthY = Math.abs(depth.y)

            # Resolve the collision along the shallow axis.
            if absDepthY < absDepthX or collision is Enum.TileCollision.Platform

              # If we crossed the top of a tile, we are on the ground.
              @IsOnGround = true  if @previousBottom <= tileBounds.top()

              # Ignore platforms, unless we are on the ground.
              if collision is Enum.TileCollision.Impassable or @IsOnGround

                # Resolve the collision along the Y axis.
                @y = @y + depth.y

                # Perform further collisions with the new bounds.
                bounds = @BoundingRectangle()
            else if collision is Enum.TileCollision.Impassable # Ignore platforms.

              # Resolve the collision along the X axis.
              @x = @x + depth.x

              # Perform further collisions with the new bounds.
              bounds = @BoundingRectangle()
        ++x
      ++y

    # Save the new bounds bottom.
    @previousBottom = bounds.bottom()


  #/ <summary>
  #/ Called when the player has been killed.
  #/ </summary>
  #/ <param name="killedBy">
  #/ The enemy who killed the player. This parameter is null if the player was
  #/ not killed by an enemy (fell into a hole).
  #/ </param>
  OnKilled: (killedBy) ->
    @IsAlive = false
    @velocity = new Point(0, 0)

    # Playing the proper animation based on
    # the current direction of our hero
    if @direction is 1
      @gotoAndPlay "die_h"
    else
      @gotoAndPlay "die"
    if killedBy isnt null and killedBy isnt `undefined`
      window.Game.Content.playSound('PlayerKilled')
    else
      window.Game.Content.playSound('PlayerFall')


  #/ <summary>
  #/ Called when this player reaches the level's exit.
  #/ </summary>
  OnReachedExit: ->
    @HasReachedExit = true
    window.Game.Content.playSound('ExitReached')

    # Playing the proper animation based on
    # the current direction of our hero
    if @direction is 1
      @gotoAndPlay "celebrate_h"
    else
      @gotoAndPlay "celebrate"

window.Player = Player
