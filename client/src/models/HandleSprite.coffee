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
          @worldPos = @nextPos = p
          window.Game.recordingHandleDragged(@, false)

      e.addEventListener 'mouseup', (e) =>
        @dragging = false
        @worldPos = @nextPos = new Point(Math.round((e.stageX - grabX) / Tile.WIDTH), Math.round((e.stageY - grabY) / Tile.HEIGHT))
        window.Game.recordingHandleDragged(@, true)

    @positionWithExtent(extent)
    @


  positionWithExtent: (extent) ->
    if @side == 'left'
      @nextPos = new Point(extent.left - 1, extent.top + (extent.bottom - extent.top) / 2)
    else if @side == 'right'
      @nextPos = new Point(extent.right + 1, extent.top + (extent.bottom - extent.top) / 2)
    else if @side == 'top'
      @nextPos = new Point(extent.left + (extent.right - extent.left) / 2, extent.top - 1)
    else
      @nextPos = new Point(extent.left + (extent.right - extent.left) / 2, extent.bottom + 1)
    @tick(0)


window.HandleSprite = HandleSprite