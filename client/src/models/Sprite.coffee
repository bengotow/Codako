
class Sprite extends BitmapAnimation

  constructor: (position, size) ->
    @worldPos = position
    @previousPos = position
    @worldSize = size
    @elapsed = 0
    @selected = false
    graphics = new createjs.Graphics().beginFill("#ff0000").drawRect(0, 0, Tile.HEIGHT, Tile.WIDTH);
    @hitArea = new createjs.Shape(graphics);



  setSpriteSheet: (sheet) ->
    Sprite.__super__.initialize.call(@, sheet)
    @gotoAndStop(0)


  createSpriteSheet: (image, animations = {idle: [0,0]}) ->
    sheet = new SpriteSheet(
      images: [image] #image to use
      animations: animations
      frames:
        width: Tile.WIDTH * @worldSize.width
        height: Tile.HEIGHT * @worldSize.height
        regX: 0
        regY: 0
    )
    SpriteSheetUtils.addFlippedFrames(sheet, true, false, false)
    @setSpriteSheet(sheet)


  tick: (elapsed) ->
    @previousPos = null
    @x = @worldPos.x * Tile.WIDTH
    @y = @worldPos.y * Tile.HEIGHT
    @

  setWorldPos: (p_or_x, y) ->
    @previousPos ||= @worldPos
    if y
      @worldPos = new Point(p_or_x, y)
    else
      @worldPos = new Point(p_or_x.x, p_or_x.y)


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
