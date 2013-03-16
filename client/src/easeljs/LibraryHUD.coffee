class LibraryHUD

  constructor: (stage) ->
    @stage = stage
    @stamps = []

    s = new DisplayObject()
    s.draw = (ctx, ignoreCache) =>
      ctx.fillStyle = 'rgba(200,200,200,255)'
      ctx.fillRect(0,0, @stage.canvas.width, 70)
      ctx.font = "14px Arial"
      ctx.fillStyle = 'rgba(0,0,0,1)'
      ctx.fillText("Hello World", 10, 15)
      true

    s.x = 0
    s.y = @stage.canvas.height - 70
    @stage.addChild(s)
    @reload()

  reload: () ->
    return unless window.Game.library.definitions
    @stage.removeChild(stamp) for stamp in @stamps

    x = 5
    y = @stage.canvas.height - 45
    for identifier, def of window.Game.library.definitions
      @_createStampSprite(x, y, identifier)
      x += 50

  update: () ->


  _createStampSprite: (x, y, identifier) ->
    descriptor = {identifier: identifier}
    sprite = window.Game.library.instantiateActorFromDescriptor(descriptor)
    sprite.x = x
    sprite.y = y
    sprite.dropped = (point) ->
      if point.x < window.Game.width || point.y < window.Game.height
        window.Game.onActorPlaced({identifier: identifier, position: point})
      @dragging = false
      @alpha = 1
      @x = x
      @y = y

    @stage.addChild(sprite)



window.LibraryHUD = LibraryHUD