class HandleSprite extends Sprite

  constructor: (side, extent) ->
    super(new Point(0,0), {width:1, height:1}, null)

    @side = side
    @createSpriteSheet(window.Game.content.imageNamed("handle_#{side}"))
    @dragging = false

    @addEventListener 'mousedown', (e) =>
      grabX = e.stageX - @x
      grabY = e.stageY - @y
      @dragging = true

      e.addEventListener 'mousemove', (e) =>
        p = new Point(Math.round((e.stageX - grabX) / Tile.WIDTH), Math.round((e.stageY - grabY) / Tile.HEIGHT))
        if @worldPos.x != p.x || @worldPos.y != p.y
          @setWorldPos(p)
          window.Game.recordingHandleDragged(@, false)

      e.addEventListener 'mouseup', (e) =>
        @dragging = false
        @setWorldPos(Math.round((e.stageX - grabX) / Tile.WIDTH), Math.round((e.stageY - grabY) / Tile.HEIGHT))
        window.Game.recordingHandleDragged(@, true)

    @positionWithExtent(extent)
    @


  positionWithExtent: (extent) ->
    if @side == 'left'
      @setWorldPos(extent.left - 1, extent.top + (extent.bottom - extent.top) / 2)
    else if @side == 'right'
      @setWorldPos(extent.right + 1, extent.top + (extent.bottom - extent.top) / 2)
    else if @side == 'top'
      @setWorldPos((extent.right + extent.left) / 2, extent.top - 1)
    else
      @setWorldPos((extent.right + extent.left) / 2, extent.bottom + 1)
    @tick(0)


window.HandleSprite = HandleSprite