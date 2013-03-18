class HandleSprite extends Sprite

  constructor: (side, extent) ->
    if side == 'left'
      position = new Point(extent.left - 1, extent.top + (extent.bottom - extent.top) / 2)
    else if side == 'right'
      position = new Point(extent.right + 1, extent.top + (extent.bottom - extent.top) / 2)
    else if side == 'top'
      position = new Point(extent.left + (extent.right - extent.left) / 2, extent.top - 1)
    else
      position = new Point(extent.left + (extent.right - extent.left) / 2, extent.bottom + 1)

    super(position, {width:1, height:1}, null)
    @createSpriteSheet(window.Game.content.imageNamed("handle_#{side}"))

    graphics = new createjs.Graphics().beginFill("#ff0000").drawRect(0, 0, Tile.HEIGHT, Tile.WIDTH);
    @hitArea = new createjs.Shape(graphics);
    @side = side

    @dragging = false
    @addEventListener 'mousedown', (e) =>
      grabX = e.stageX - @x
      grabY = e.stageY - @y
      @dragging = true

      e.addEventListener 'mousemove', (e) =>
        p = new Point(Math.round((e.stageX - grabX) / Tile.WIDTH), Math.round((e.stageY - grabY) / Tile.HEIGHT))
        if @worldPos.x != p.x || @worldPos.y != p.y
          @worldPos = @nextPos = p
          window.Game.onHandleDragged(@)

      e.addEventListener 'mouseup', (e) =>
        @dragging = false

  hitTest: (x,y) ->
    debugger
    true

window.HandleSprite = HandleSprite