class Gem extends Bitmap
  # Bounce control constants
  localBounds = undefined
  BounceHeight = 0.18
  BounceRate = 3.0
  BounceSync = -0.75

  @PointValue = 30

  constructor: (texture, level, position) ->
    Gem.__super__.initialize.call(@, texture)

    @level = level
    @x = position.x * 40
    @y = position.y * 32

    # The gem is animated from a base position along the Y axis.
    @basePosition = new Point(@x, @y)
    @frameWidth = texture.width
    @frameHeight = texture.height
    @width = @frameWidth * 0.8
    @left = @frameWidth / 2
    @height = @frameWidth * 0.8
    @top = @frameHeight - @height
    @localBounds = new XNARectangle(@left, @top, @width, @height)
    @


  BoundingRectangle: ->
    left = Math.round(@x) + @localBounds.x
    top = Math.round(@y) + @localBounds.y
    new XNARectangle(left, top, @localBounds.width, @localBounds.height)


  tick: ->
    t = (Ticker.getTime() / 1000) * BounceRate + @x * BounceSync
    bounce = Math.sin(t) * BounceHeight * 32
    @y = @basePosition.y + bounce

  window.Gem = Gem
