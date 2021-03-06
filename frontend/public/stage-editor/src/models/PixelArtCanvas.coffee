  
class PixelTool

  constructor: ->
    @down = false
    @name = 'Undefined'
    @autoApplyChanges = true
    @reset()

  mousedown: (point, canvas) ->
    @down = true
    @s = point
    @e = point

  mousemove: (point, canvas) ->
    return unless @down
    @e = point

  mouseup: (point, canvas) ->
    return unless @down
    @down = false
    @e = point

  previewRender: (context,canvas) ->
    @render(context,canvas)

  render: (context) ->

  renderLine: (context,x0,y0,x1,y1,color=null, method=null) ->
    method ||= context.fillPixel #add a default value (we can't reference one parameter from another in the prototype)

    dx = Math.abs(x1 - x0)
    dy = Math.abs(y1 - y0)
    if x0 < x1 then sx = 1 else sx = -1
    if y0 < y1 then sy = 1 else sy = -1
    err = dx - dy

    while true
      method(x0,y0,color)
      return if x0 == x1 and y0 == y1

      e2 = 2 * err
      if e2 > -dy
        err = err - dy
        x0 = x0 + sx

      if e2 <  dx
        err = err + dx
        y0 = y0 + sy

  reset: ->
    @s = @e = null


class PixelFillRectTool extends PixelTool

  constructor: ->
    super
    @name = 'rect'

  render: (context) ->
    return unless @s && @e
    for x in [@s.x..@e.x]
      for y in [@s.y..@e.y]
        context.fillPixel(x,y)


class PixelPaintbucketTool extends PixelTool

  constructor: ->
    super
    @name = 'paintbucket'

  render: (context, canvas) ->
    return unless @e
    canvas.getContiguousPixels @e, canvas.selectedPixels, (p) ->
      context.fillPixel( p.x, p.y )


class PixelFillEllipseTool extends PixelTool

  constructor: ->
    super
    @name = 'ellipse'

  render: (context) ->
    return unless @s && @e

    rx = (@e.x - @s.x) / 2
    ry = (@e.y - @s.y) / 2
    cx = Math.round(@s.x + rx)
    cy = Math.round(@s.y + ry)

    for x in [@s.x..@e.x]
      for y in [@s.y..@e.y]
        if Math.pow((x-cx) / rx, 2) + Math.pow((y-cy) / ry, 2) < 1
          context.fillPixel(x,y)


class PixelFreehandTool extends PixelTool

  constructor: ->
    super
    @name = 'pen'

  mousedown: (point) ->
    @down = true
    @points.push(point)

  mousemove: (point) ->
    return unless @down
    @points.push(point)

  mouseup: (point) ->
    return unless @down
    @down = false
    @points.push(point)

  reset: ->
    @points = []

  render: (context) ->
    return unless @points.length
    prev = @points[0]
    for point in @points
      @renderLine(context, prev.x,prev.y,point.x,point.y)
      prev = point


class PixelLineTool extends PixelTool

  constructor: ->
    super
    @name = 'line'

  render: (context) ->
    return unless @s && @e
    @renderLine(context, @s.x,@s.y,@e.x,@e.y)


class PixelEraserTool extends PixelTool

  constructor: ->
    super
    @name = 'eraser'

  mousedown: (point) ->
    @down = true
    @points.push(point)

  mousemove: (point) ->
    return unless @down
    @points.push(point)

  mouseup: (point) ->
    return unless @down
    @down = false
    @points.push(point)

  reset: ->
    @points = []

  previewRender: (context, canvas) ->
    prev = @points[0]
    for point in @points
      @renderLine(context, prev.x,prev.y,point.x,point.y, "rgba(0,0,0,0)", context.clearPixel )
      prev = point

  render: (context,canvas) ->
    return unless @points.length
    prev = @points[0]
    for point in @points
      @renderLine(context, prev.x,prev.y,point.x,point.y, "rgba(0,0,0,0)")
      prev = point


class PixelRectSelectionTool extends PixelTool

  constructor: ->
    super
    @name = 'select'
    #@autoApplyChanges = false

  mouseup: (point) ->
    return unless @down
    @down = false
    @e = point


  render: (context,canvas) ->
    return unless @s && @e
    return unless context instanceof CanvasRenderingContext2D

    canvas.selectedPixels = []
    return if @s.x == @e.x or @s.y == @e.y

    for sel_x in [@s.x..@e.x-1]
      for sel_y in [@s.y..@e.y-1]
        canvas.selectedPixels.push( {x:sel_x, y:sel_y} )

  reset: ->
    @s = @e = null


class PixelMagicSelectionTool extends PixelTool

  constructor: ->
    super
    @name = 'magicWand'
    #@autoApplyChanges = false

  render: (context,canvas) ->
    return unless @e
    canvas.selectedPixels = []
    canvas.getContiguousPixels @e, null, (p) ->
      canvas.selectedPixels.push( p )


class PixelTranslateTool extends PixelTool

  constructor: ->
    super
    @name = 'translate'

  mousedown: (point, canvas) ->
    @down = true
    return unless canvas.selectedPixels.length
    canvas.cut()
    canvas.paste()


class PixelArtCanvas

  constructor: (image, canvas, controller_scope) ->
    @controller = controller_scope
    @canvas = canvas
    @width = canvas.width
    @height = canvas.height
    @image = image
    @tools = [new PixelRectSelectionTool(), new PixelMagicSelectionTool(), new PixelTranslateTool(), new PixelFreehandTool(), new PixelEraserTool(), new PixelLineTool(), new PixelFillEllipseTool(), new PixelFillRectTool(), new PixelPaintbucketTool()]
    @tool = @tools[0]
    @toolColor = "rgba(0,0,0,255)"
    @pixelSize = Math.floor(@width / Tile.WIDTH)
    canvas.width = @width
    canvas.height = @height
    canvas.addEventListener('mousedown', @handleCanvasEvent, false)
    canvas.addEventListener('mousemove', @handleCanvasEvent, false)
    canvas.addEventListener('mouseup',   @handleCanvasEvent, false)
    canvas.addEventListener('mouseout',  @handleCanvasEvent, false)
    Ticker.addListener(@)

    $('body').keydown @handleKeyEvent
    $(canvas).css('cursor', 'crosshair')

    # augment our context object
    @context = canvas.getContext("2d")

    @context.drawTransparentPattern = =>
      for x in [0..@imageData.width]
        for y in [0..@imageData.height]
          @context.fillStyle = "rgba(230,230,230,1)"
          @context.fillRect(x * @pixelSize, y * @pixelSize, @pixelSize / 2, @pixelSize / 2)
          @context.fillRect(x * @pixelSize + @pixelSize / 2, y * @pixelSize + @pixelSize / 2, @pixelSize / 2, @pixelSize / 2)

    @context.fillPixel = (x, y, color = @toolColor) =>
      if color[-3..-1] != ',0)'
        @context.fillStyle = color
        @context.fillRect(x * @pixelSize, y * @pixelSize, @pixelSize, @pixelSize)

    @context.clearPixel = (x, y ) =>
       @context.clearRect(x * @pixelSize, y * @pixelSize, @pixelSize, @pixelSize)

    @draggingPasteData = false
    @dragData = @context.createImageData( Tile.WIDTH, Tile.HEIGHT )
    @_extendImageData( @dragData )
    @dragData.offsetX = 0
    @dragData.offsetY = 0
    @dragStart = {x:0, y:0}
    @selectedPixels = []

    # generate initial image of the workspace
    @setDisplayedFrame(0)

  setImage: (img) ->
    @image = img
    @setDisplayedFrame(0)
    @render()

  setDisplayedFrame: (index, saveChanges = false) ->
    @pasteFinishDrag(false) if @draggingPasteData

    @undoStack = []
    @redoStack = []

    @image.onload = =>
      @prepareDataForDisplayedFrame()
      @render()
    @image.src = @dataURLRepresentation() if saveChanges
    @imageDisplayedFrame = index
    @prepareDataForDisplayedFrame()
    @render()


  stagePointToPixel: (x, y) ->
    new Point( Math.max(0, Math.min( Math.round(x / @pixelSize), Tile.WIDTH )) , Math.max(0, Math.min( Math.round(y / @pixelSize), Tile.HEIGHT ) ) )


  handleKeyEvent: (ev) =>
    return true unless $(@canvas).is(':visible')

    if @draggingPasteData == true
      @pasteFinishDrag() if ev.keyCode == 13
      @dragData.offsetY -= @pixelSize if ev.keyCode == 38
      @dragData.offsetY += @pixelSize if ev.keyCode == 40
      @dragData.offsetX -= @pixelSize if ev.keyCode == 37
      @dragData.offsetX += @pixelSize if ev.keyCode == 39
      @render()

    if ev.keyCode == 8 or ev.keyCode == 46
      ev.preventDefault()
      return unless @selectedPixels
      @undoStack.push(new Uint8ClampedArray(@imageData.data))
      @redoStack = []
      @clearPixels( @selectedPixels )
      @selectedPixels = [] # deselection makes things look cleaner in the editor.
      @render()

    @copy() if ev.keyCode == 67 and ev.metaKey
    @cut() if ev.keyCode == 88 and ev.metaKey
    @paste() if ev.keyCode == 86 and ev.metaKey
    @selectAll() if ev.keyCode == 65 and ev.metaKey
    @flip('x') if ev.keyCode == 72
    @flip('y') if ev.keyCode == 74

    if ev.keyCode == 90 and ev.metaKey and ev.shiftKey
      ev.preventDefault()
      @redo()
      window.rootScope.$apply() unless window.rootScope.$$phase
    else if ev.keyCode == 90 and ev.metaKey
      ev.preventDefault()
      @undo()
      window.rootScope.$apply() unless window.rootScope.$$phase


  handleCanvasEvent: (ev) =>
    return unless @tool

    type = ev.type
    evX = ev.offsetX
    evY = ev.offsetY

    # if you're dragging and release the mouse outside of the canvas,
    # we never get a mouse up event. When the mouse re-enters and we get
    # an event, we detect that the mouse is no loger down and close the previous
    # tool action.
    if @tool.down && !window.mouseIsDown
      type = 'mouseup'
      evX = @mouseLastOffsetX
      evY = @mouseLastOffsetY

    @mouseLastOffsetX = evX
    @mouseLastOffsetY = evY

    if @draggingPasteData == false
      type = 'mousemove' if type == 'mouseout' && !@tool[type]
      @tool[type](@stagePointToPixel(evX, evY), @) if @tool[type]
      @applyTool() if type == 'mouseup' and @tool.autoApplyChanges == true
      @render()
    else
      if type == 'mousedown'
        @dragStart.x = evX - @dragData.offsetX
        @dragStart.y = evY - @dragData.offsetY
      if type == 'mousemove' && window.mouseIsDown
        @dragData.offsetX = Math.floor((evX-@dragStart.x) / @pixelSize) * @pixelSize
        @dragData.offsetY = Math.floor((evY-@dragStart.y) / @pixelSize) * @pixelSize

      @render()


  selectAll: =>
    @selectedPixels = []
    for x in [0..Tile.WIDTH-1]
      for y in [0..Tile.HEIGHT-1]
        @selectedPixels.push({x:x, y:y})


  canCopy: ->
    @selectedPixels.length

  copy: =>
    @clipboardData = new Uint8ClampedArray( Tile.WIDTH * Tile.HEIGHT * 4 )

    for p in @selectedPixels
      @clipboardData[ (p.y * Tile.WIDTH + p.x) * 4 + 0 ] = @imageData.data[ (p.y * Tile.WIDTH + p.x) * 4 + 0 ]
      @clipboardData[ (p.y * Tile.WIDTH + p.x) * 4 + 1 ] = @imageData.data[ (p.y * Tile.WIDTH + p.x) * 4 + 1 ]
      @clipboardData[ (p.y * Tile.WIDTH + p.x) * 4 + 2 ] = @imageData.data[ (p.y * Tile.WIDTH + p.x) * 4 + 2 ]
      @clipboardData[ (p.y * Tile.WIDTH + p.x) * 4 + 3 ] = @imageData.data[ (p.y * Tile.WIDTH + p.x) * 4 + 3 ]

    window.rootScope.$apply() unless window.rootScope.$$phase


  cut: =>
    @copy()
    @clearPixels(@selectedPixels)


  canPaste: ->
    return true if @clipboardData
    return false

  paste: =>
    return unless @clipboardData
    @undoStack.push(new Uint8ClampedArray(@imageData.data))
    @redoStack = []

    $(@canvas).css('cursor', 'move')
    @dragData.clearRect( 0, 0, Tile.WIDTH, Tile.HEIGHT )
    @applyPixelsFromData( @clipboardData, @dragData, 0, 0, Tile.WIDTH, Tile.HEIGHT )
    @draggingPasteData = true
    @selectedPixels = [] # deselection makes things look cleaner in the editor.
    @render()


  pasteFinishDrag: (commit = true) =>
    if commit
      @applyPixelsFromData( @dragData.data, @imageData, 0, 0, Tile.WIDTH, Tile.HEIGHT, Tile.WIDTH, Math.floor(@dragData.offsetX / @pixelSize), Math.floor(@dragData.offsetY / @pixelSize), {ignoreClearPixels: true})
    $(@canvas).css('cursor', 'crosshair')
    @draggingPasteData = false


  clearPixels: ( pixels ) =>
    for p in pixels
      @imageData.clearRect( p.x, p.y, p.x+1, p.y+1 )


  tick: ->
    # for the fun marching-ants selection areas.
    if @selectedPixels?.length
      @render()


  render: ->
    @context.fillStyle = "rgb(255,255,255)"
    @context.clearRect(0,0, @width, @height)
    @context.drawTransparentPattern()

    @applyPixelsFromData(@imageData.data, @context)

    if @draggingPasteData == true
      # grey out all things not being dragged.
      @context.fillStyle = "rgba(0,0,0,0.3)"
      @context.fillRect( 0,0, @width, @height )

      # draw the drag buffer.
      @context.translate( @dragData.offsetX, @dragData.offsetY )
      @applyPixelsFromData(@dragData.data, @context, 0, 0, @dragData.width, @dragData.height, @dragData.width)
      @context.translate( -@dragData.offsetX, -@dragData.offsetY )

    @tool.previewRender(@context, @) if @tool

    # draw selected pixels with marching ant funtimes.
    # for p in @selectedPixels
    #   @context.fillPixel(p.x, p.y, "rgba(0, 0, 0, 0.2)")
    @context.lineWidth = 1
    @context.strokeStyle = "rgba(70,70,70,.90)"
    @context.beginPath()
    @getBorderPixels @selectedPixels, (x,y, left, right, top, bot) => 
      if (Math.floor( Ticker.getTime() / 250 ) + x + y * (Tile.WIDTH+1)) % 2 == 0
        topY = (y)*@pixelSize
        botY = (y+1)*@pixelSize
        leftX = (x)*@pixelSize
        rightX = (x+1)*@pixelSize
        if !left
          @context.moveTo( leftX, topY )
          @context.lineTo( leftX, botY )
        if !right
          @context.moveTo( rightX, topY )
          @context.lineTo( rightX, botY )
        if !top
          @context.moveTo( leftX, topY )
          @context.lineTo( rightX, topY )
        if !bot
          @context.moveTo( leftX, botY )
          @context.lineTo( rightX, botY )
    @context.stroke()
    #end marching ant funtimes.

    @context.lineWidth = 1
    @context.strokeStyle = "rgba(70,70,70,.30)"
    @context.beginPath()
    for x in [0..Tile.WIDTH+1]
      @context.moveTo(x * @pixelSize + 0.5, 0)
      @context.lineTo(x * @pixelSize + 0.5, @height * @pixelSize + 0.5)

    for y in [0..Tile.HEIGHT+1]
      @context.moveTo(0, y * @pixelSize + 0.5)
      @context.lineTo(@width * @pixelSize + 0.5, y * @pixelSize + 0.5)
    @context.stroke()


  applyTool: ->
    @undoStack.push(new Uint8ClampedArray(@imageData.data))
    @redoStack = []
    @tool.render(@imageData, @)
    @tool.reset()
    window.rootScope.$apply() unless window.rootScope.$$phase


  applyTransformation: (pixelProvider) =>
    if @draggingPasteData
      imagedata = @dragData
    else
      @undoStack.push(new Uint8ClampedArray(@imageData.data))
      imagedata = @imageData

    oldData = new Uint8ClampedArray(imagedata.data)
    for x in [0..imagedata.width-1]
      for y in [0..imagedata.height-1]
        [newX, newY] = pixelProvider(x,y)

        index = (y * imagedata.width + x) * 4
        indexNew = (newY * imagedata.width + newX) * 4
        for channel in [0..3]
          imagedata.data[indexNew+channel] = oldData[index+channel]

    @render()
    window.rootScope.$apply() unless window.rootScope.$$phase


  applyPixelsFromData: (data, target, startX=0, startY=0, endX=Tile.WIDTH, endY=Tile.HEIGHT, dataWidth=Tile.WIDTH, offsetX = 0, offsetY = 0, options = {}) ->
    for x in [startX..endX-1]
      for y in [startY..endY-1]
        r = data[(y * dataWidth + x) * 4 + 0]
        g = data[(y * dataWidth + x) * 4 + 1]
        b = data[(y * dataWidth + x) * 4 + 2]
        a = data[(y * dataWidth + x) * 4 + 3]
        target.fillPixel(x+offsetX,y+offsetY,"rgba(#{r},#{g},#{b},#{a})") unless options.ignoreClearPixels && a <= 0


  flip: (dir) =>
    if dir == 'x'
      @applyTransformation (x,y) -> [(Tile.WIDTH-1) - x, y]
    else
       @applyTransformation (x,y) -> [x, (Tile.HEIGHT-1) - y]

  rotate: (deg) =>
    if deg == 90
      @applyTransformation (x,y) -> [(Tile.HEIGHT-1) - y,x]
    else if deg == -90
       @applyTransformation (x,y) -> [y,(Tile.WIDTH-1)-x]


  copyPixelsFromData: (data, target, startX=0, startY=0, endX=Tile.WIDTH, endY=Tile.HEIGHT, dataWidth=Tile.WIDTH) ->
    # CONSIDER REVISION
    w = endX - startX
    h = endY - startY

    for x in [0..w-1]
      for y in [0..h-1]
        # Make 4 copies to account for each color channel.
        target[ (y*w + x) * 4 + 0 ] = data[ ((startY+y) * dataWidth + (startX+x)) * 4 + 0 ]
        target[ (y*w + x) * 4 + 1 ] = data[ ((startY+y) * dataWidth + (startX+x)) * 4 + 1 ]
        target[ (y*w + x) * 4 + 2 ] = data[ ((startY+y) * dataWidth + (startX+x)) * 4 + 2 ]
        target[ (y*w + x) * 4 + 3 ] = data[ ((startY+y) * dataWidth + (startX+x)) * 4 + 3 ]


  getContiguousPixels: (startPixel, region, callback ) =>
    points = [startPixel]
    startPixelData = @imageData.getPixel( startPixel.x, startPixel.y)
    pointsHit =  {}
    pointsHit[ "#{startPixel.x}-#{startPixel.y}" ] = 1

    while (p = points.pop())
      callback(p)

      for d in [{x:-1, y:0}, {x:0,y:1}, {x:0,y:-1}, {x:1,y:0}]
        pp = new Point(p.x + d.x, p.y + d.y)
        continue unless pp.x >= 0 && pp.y >= 0 && pp.x < Tile.WIDTH && pp.y < Tile.HEIGHT
        continue if region?.length and !_.find region, (test) -> pp.x == test.x && pp.y == test.y
        continue if pointsHit["#{pp.x}-#{pp.y}"]

        pixelData = @imageData.getPixel(pp.x, pp.y)
        colorDelta = 0
        colorDelta += Math.abs(pixelData[i] - startPixelData[i]) for i in [0..3]
        if colorDelta < 15
          points.push(pp)
          pointsHit["#{pp.x}-#{pp.y}"] = true


  #this function calls a callback on every pixel on the border of a group of pixels
  getBorderPixels: ( pixels, callback ) =>
    for p in pixels
      left = right = top = bot = false
      for other in pixels
        left = true if other.x == p.x-1 and other.y == p.y
        right = true if  other.x == p.x+1 and other.y == p.y
        top = true if  other.x == p.x and other.y == p.y-1
        bot = true if  other.x == p.x and other.y == p.y+1

      if not left or not right or not top or not bot
        callback( p.x, p.y, left, right, top, bot )


  canUndo: ->
    @undoStack.length


  undo: ->
    return unless @canUndo()
    @redoStack.push(new Uint8ClampedArray(@imageData.data))
    @applyPixelsFromData(@undoStack.pop(), @imageData)
    @render()


  canRedo: ->
    @redoStack.length


  redo: ->
    return unless @canRedo()
    @undoStack.push(new Uint8ClampedArray(@imageData.data))
    @applyPixelsFromData(@redoStack.pop(), @imageData)
    @render()


  coordsForFrame: (frame) ->
    x = frame % (@image.width / Tile.WIDTH)
    y = Math.floor(frame / (@image.width / Tile.WIDTH))
    [x  * Tile.WIDTH, y * Tile.HEIGHT]


  dataURLRepresentation: ->
    [x,y] = @coordsForFrame(@imageDisplayedFrame)

    totalWidth = Math.max(@image.width, x + Tile.WIDTH)
    totalHeight = Math.max(@image.height, y + Tile.HEIGHT)

    url = false
    window.withTempCanvas totalWidth, totalHeight, (canvas, context) =>
      context.drawImage(@image, 0, 0) if @image
      context.putImageData(@imageData, x, y)
      url = canvas.toDataURL()

    {data: url, width: totalWidth}

  dataURLRepresentationForDisplayedFrame: ->
    url = false
    window.withTempCanvas Tile.WIDTH, Tile.HEIGHT, (canvas, context) =>
      context.putImageData(@imageData, 0, 0)
      url = canvas.toDataURL()
    {data: url, width: Tile.WIDTH}



  prepareDataForDisplayedFrame: ->
    window.withTempCanvas Tile.WIDTH, Tile.HEIGHT, (canvas, context) =>
      [x, y] = @coordsForFrame(@imageDisplayedFrame)
      context.imageSmoothingEnabled = false
      context.clearRect(0,0, @width, @height)
      context.drawImage(@image, -x, -y) if @image
      @imageData = context.getImageData(0, 0, canvas.width, canvas.height)
    @_extendImageData(@imageData)
    @imageData


    # this just restores all persistent stuff to its default values... FUN :D
  cleanup: =>
    @pasteFinishDrag() if @draggingPasteData
    @dragData.clearRect( 0, 0, Tile.WIDTH, Tile.HEIGHT )
    @dragStart = {x:0, y:0}
    @selectedPixels = []
    @render()

  _extendImageData: (imgData) ->
    imgData.fillPixel = (xx, yy, color = @toolColor) =>
      return if xx >= Tile.WIDTH || xx < 0
      return if yy >= Tile.HEIGHT || yy < 0

      components = color[5..-2].split(',')
      for i in [0..components.length-1]
        imgData.data[(yy * Tile.WIDTH + xx) * 4 + i] = components[i]/1
    imgData.getPixel = (xx, yy) ->
      oo = (yy * Tile.WIDTH + xx) * 4
      [@data[oo],@data[oo+1],@data[oo+2],@data[oo+3]]
    imgData.clearRect = ( startX, startY, endX, endY ) ->
      return unless (endX-startX) > 0 and (endY-startY) > 0
      for x in [startX..endX-1]
        for y in [startY..endY-1]
          @fillPixel( x, y, 'rgba(0,0,0,0)' )



window.PixelArtCanvas = PixelArtCanvas