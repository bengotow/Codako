
  # Index used for the naming of the monsters
  Enemy = (level, position, imgMonster) ->
    @initialize level, position, imgMonster

  MaxWaitTime = 0.5
  MoveSpeed = 64.0
  localBounds = undefined
  monsterIndex = 0
  globalTargetFPS = 17
  Enemy:: = new BitmapAnimation()

  # constructor:
  Enemy::BitmapAnimation_initialize = Enemy::initialize
  Enemy::initialize = (level, position, imgMonster) ->
    width = undefined
    left = undefined
    height = undefined
    top = undefined
    frameWidth = undefined
    frameHeight = undefined
    localSpriteSheet = new SpriteSheet(
      images: [imgMonster] #image to use
      frames:
        width: 64
        height: 64
        regX: 32
        regY: 64

      animations:
        walk: [0, 9, "walk", 4]
        idle: [10, 20, "idle", 4]
    )
    SpriteSheetUtils.addFlippedFrames localSpriteSheet, true, false, false
    @BitmapAnimation_initialize localSpriteSheet
    @x = position.x
    @y = position.y
    @level = level

    #/ <summary>
    #/ How long this enemy has been waiting before turning around.
    #/ </summary>
    @waitTime = 0
    frameWidth = @spriteSheet.getFrame(0).rect.width
    frameHeight = @spriteSheet.getFrame(0).rect.height

    # Calculate bounds within texture size.
    width = parseInt(frameWidth * 0.35)
    left = parseInt((frameWidth - width) / 2)
    height = parseInt(frameWidth * 0.7)
    top = parseInt(frameHeight - height)
    localBounds = new XNARectangle(left, top, width, height)

    # start playing the first sequence:
    @gotoAndPlay "walk_h" #animate

    # set up a shadow. Note that shadows are ridiculously expensive. You could display hundreds
    # of animated monster if you disabled the shadow.
    @name = "Monster" + monsterIndex
    monsterIndex++

    #/ <summary>
    #/ The direction this enemy is facing and moving along the X axis.
    #/ </summary>
    # 1 = right & -1 = left
    @direction = 1

    # starting directly at the first frame of the walk_right sequence
    @currentFrame = 21
    @

  #/ <summary>
  #/ Gets a rectangle which bounds this enemy in world space.
  #/ </summary>
  Enemy::BoundingRectangle = ->
    left = parseInt(Math.round(@x - 32) + localBounds.x)
    top = parseInt(Math.round(@y - 64) + localBounds.y)
    new XNARectangle(left, top, localBounds.width, localBounds.height)


  #/ <summary>
  #/ Paces back and forth along a platform, waiting at either end.
  #/ </summary>
  Enemy::tick = ->

    # We should normaly try here to compute the elpsed time since
    # the last update. But setTimeout/setTimer functions
    # are not predictable enough to do that. requestAnimationFrame will
    # help when the spec will be stabilized and used properly by all major browsers
    # In the meantime, we're cheating... and living in a perfect 60 FPS world ;-)
    elapsed = globalTargetFPS / 1000
    posX = @x + (localBounds.width / 2) * @direction
    tileX = Math.floor(posX / Tile.WIDTH) - @direction
    tileY = Math.floor(@y / Tile.HEIGHT)
    if @waitTime > 0

      # Wait for some amount of time.
      @waitTime = Math.max(0.0, @waitTime - elapsed)
      if @waitTime <= 0.0 and not @level.IsHeroDied and not @level.ReachedExit

        # Then turn around.
        @direction = -@direction
        if @direction is 1
          @gotoAndPlay "walk_h" #animate
        else
          @gotoAndPlay "walk" #animate
    else

      # If we are about to run into a wall or off a cliff, start waiting.
      if @level.GetCollision(tileX + @direction, tileY - 1) is Enum.TileCollision.Impassable or @level.GetCollision(tileX + @direction, tileY) is Enum.TileCollision.Passable or @level.IsHeroDied or @level.ReachedExit
        @waitTime = MaxWaitTime
        @gotoAndPlay "idle"  if @currentAnimation.indexOf("idle") is -1
      else

        # Move in the current direction.
        velocity = @direction * MoveSpeed * elapsed
        @x = @x + velocity

  window.Enemy = Enemy
