
class Sprite extends BitmapAnimation

  constructor: (position, size, level) ->
    @worldPos = position
    @nextPos = position
    @worldSize = size
    @level = level
    @elapsed = 0
    @selected = false


  createSpriteSheet: (name, animations) ->
    sheet = new SpriteSheet(
      images: [window.Game.Content.imageNamed(name)] #image to use
      animations: animations
      frames:
        width: Tile.WIDTH * @worldSize.width
        height: Tile.HEIGHT * @worldSize.height
        regX: 0
        regY: 0
    )
    SpriteSheetUtils.addFlippedFrames(sheet, true, false, false)
    Sprite.__super__.initialize.call(@, sheet)
    @gotoAndStop('idle')


  tick: (elapsed) ->
    if @nextPos
      @worldPos = @nextPos
      @x = @worldPos.x * Tile.WIDTH
      @y = @worldPos.y * Tile.HEIGHT


  setSelected: (sel) ->
    @selected = sel
    @shadow = null
    @shadow = new Shadow("#FFF", 2, 2, 9) if @selected


  getBounds: () ->
    super


  getWorldBounds: () ->
    new XNARectangle(@worldPos.x, @worldPos.y, @worldSize.width, @worldSize.height)


  intersects: (otherSprite) ->
    false


window.Sprite = Sprite
