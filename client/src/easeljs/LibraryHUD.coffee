class LibraryHUD

  constructor: (stage) ->
    @stage = stage
    @stamps = []

    g = new Graphics()
    g.beginFill(Graphics.getRGB(200,200,200))
    g.drawRect(0,0,@stage.canvas.width, 50)

    s = new Shape(g)
    s.x = 0
    s.y = @stage.canvas.height - 50
    @stage.addChild(s)
    @reload()

  reload: () ->
    return unless window.Game.Library.definitions
    x = 5
    y = @stage.canvas.height - 45
    for identifier, def of window.Game.Library.definitions
      @_createStampSprite(x, y, identifier)
      x += 50

  update: () ->


  _createStampSprite: (x, y, identifier) ->
    descriptor = {identifier: identifier}
    sprite = window.Game.Library.instantiateActorFromDescriptor(descriptor)
    sprite.x = x
    sprite.y = y
    sprite.dropped = (point) ->
      window.Game.Manager.level.onActorPlaced({identifier: identifier, position: point})
      @dragging = false
      @alpha = 1
      @x = x
      @y = y

    @stage.addChild(sprite)



window.LibraryHUD = LibraryHUD