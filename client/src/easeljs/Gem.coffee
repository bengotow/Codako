  # Bounce control constants
  Gem = (texture, level, position) ->
    @initialize texture, level, position
  localBounds = undefined
  BounceHeight = 0.18
  BounceRate = 3.0
  BounceSync = -0.75
  Gem:: = new Bitmap()

  # constructor:
  #unique to avoid overiding base class
  Gem::Bitmap_initialize = Gem::initialize
  Gem::initialize = (texture, level, position) ->
    width = undefined
    left = undefined
    height = undefined
    top = undefined
    frameWidth = undefined
    frameHeight = undefined
    @Bitmap_initialize texture
    @level = level
    @x = position.x * 40
    @y = position.y * 32
    @shadow = new Shadow("#000", 3, 2, 2)  if enableShadows

    # The gem is animated from a base position along the Y axis.
    @basePosition = new Point(@x, @y)
    frameWidth = texture.width
    frameHeight = texture.height
    width = frameWidth * 0.8
    left = frameWidth / 2
    height = frameWidth * 0.8
    top = frameHeight - height
    localBounds = new XNARectangle(left, top, width, height)

    @


  Gem::PointValue = 30

  #/ <summary>
  #/ Bounces up and down in the air to entice players to collect them.
  #/ </summary>
  Gem::BoundingRectangle = ->
    left = Math.round(@x) + localBounds.x
    top = Math.round(@y) + localBounds.y
    new XNARectangle(left, top, localBounds.width, localBounds.height)


  #/ <summary>
  #/ Bounces up and down in the air to entice players to collect them.
  #/ </summary>
  Gem::tick = ->

    # Bounce along a sine curve over time.
    # Include the X coordinate so that neighboring gems bounce in a nice wave pattern.
    t = (Ticker.getTime() / 1000) * BounceRate + @x * BounceSync
    bounce = Math.sin(t) * BounceHeight * 32
    @y = @basePosition.y + bounce

  window.Gem = Gem
