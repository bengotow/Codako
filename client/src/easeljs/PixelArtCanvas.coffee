
class PixelTool

  constructor: () ->
    @down = false
    @name = 'Undefined'
    @autoApplyChanges = true
    @reset()

  mousedown: (point) ->
    @down = true
    @s = point
    @e = point

  mousemove: (point) ->
    return unless @down
    @e = point

  mouseup: (point) ->
    return unless @down
    @down = false
    @e = point

  render: (context) ->

  renderLine: (context,x0,y0,x1,y1,color=null) ->
    dx = Math.abs(x1 - x0)
    dy = Math.abs(y1 - y0)
    if x0 < x1 then sx = 1 else sx = -1
    if y0 < y1 then sy = 1 else sy = -1
    err = dx - dy

    while true
      context.fillPixel(x0,y0,color)
      return if x0 == x1 and y0 == y1

      e2 = 2 * err
      if e2 > -dy
        err = err - dy
        x0 = x0 + sx

      if e2 <  dx
        err = err + dx
        y0 = y0 + sy

  reset: () ->
    @s = @e = null


class PixelFillRectTool extends PixelTool

  constructor: () ->
    super
    @name = 'rect'

  render: (context) ->
    return unless @s && @e
    for x in [@s.x..@e.x]
      for y in [@s.y..@e.y]
        context.fillPixel(x,y)


class PixelPaintbucketTool extends PixelTool

  constructor: () ->
    super
    @name = 'paintbucket'

  render: (context, canvas) ->
    return unless @e
    canvas.getContiguousPixels @e, canvas.selectedPixels, (p) ->
      context.fillPixel( p.x, p.y )


class PixelFillEllipseTool extends PixelTool

  constructor: () ->
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

  constructor: () ->
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

  reset: () ->
    @points = []

  render: (context) ->
    return unless @points.length
    prev = @points[0]
    for point in @points
      @renderLine(context, prev.x,prev.y,point.x,point.y)
      prev = point


class PixelLineTool extends PixelTool

  constructor: () ->
    super
    @name = 'line'

  render: (context) ->
    return unless @s && @e
    @renderLine(context, @s.x,@s.y,@e.x,@e.y)


class PixelEraserTool extends PixelTool

  constructor: () ->
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

  reset: () ->
    @points = []

  render: (context) ->
    return unless @points.length
    prev = @points[0]
    for point in @points
      @renderLine(context, prev.x,prev.y,point.x,point.y, "rgba(0,0,0,0)")
      prev = point


class PixelRectSelectionTool extends PixelTool

  constructor: () ->
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
    for sel_x in [@s.x..@e.x]
      for sel_y in [@s.y..@e.y]
        canvas.selectedPixels.push( {x:sel_x, y:sel_y} )

  reset: () ->
    @s = @e = null


class PixelMagicSelectionTool extends PixelTool

  constructor: () ->
    super
    @name = 'magicWand'
    #@autoApplyChanges = false

  render: (context,canvas) ->
    return unless @e
    canvas.selectedPixels = []
    canvas.getContiguousPixels @e, null, (p) ->
      canvas.selectedPixels.push( p )


class PixelArtCanvas

  constructor: (image, canvas, controller_scope) ->
    @controller = controller_scope
    @width = canvas.width
    @height = canvas.height
    @image = image
    @tools = [new PixelRectSelectionTool(), new PixelFreehandTool(), new PixelEraserTool(), new PixelMagicSelectionTool(), new PixelLineTool(), new PixelFillEllipseTool(), new PixelFillRectTool(), new PixelPaintbucketTool()]
    @tool = @tools[0]
    @toolColor = "rgba(0,0,0,255)"
    @pixelSize = Math.floor(@width / Tile.WIDTH)
    canvas.width = @width
    canvas.height = @height
    $(canvas).css('cursor', 'crosshair')
    canvas.addEventListener('mousedown', @handleCanvasEvent, false)
    canvas.addEventListener('mousemove', @handleCanvasEvent, false)
    canvas.addEventListener('mouseup',   @handleCanvasEvent, false)
    canvas.addEventListener('mouseout',  @handleCanvasEvent, false)
    $('body').keydown @handleKeyEvent

    # augment our context object
    @context = canvas.getContext("2d")

    @context.drawTransparentPattern = () =>
      for x in [0..@imageData.width]
        for y in [0..@imageData.height]
          @context.fillStyle = "rgba(230,230,230,1)"
          @context.fillRect(x * @pixelSize, y * @pixelSize, @pixelSize / 2, @pixelSize / 2)
          @context.fillRect(x * @pixelSize + @pixelSize / 2, y * @pixelSize + @pixelSize / 2, @pixelSize / 2, @pixelSize / 2)


    @context.fillPixel = (x, y, color = @toolColor) =>
      # if color[-3..-1] != ',1)'
      #   @context.fillStyle = "rgba(230,230,230,1)"
      #   @context.fillRect(x * @pixelSize, y * @pixelSize, @pixelSize / 2, @pixelSize / 2)
      #   @context.fillRect(x * @pixelSize + @pixelSize / 2, y * @pixelSize + @pixelSize / 2, @pixelSize / 2, @pixelSize / 2)
      if color[-3..-1] != ',0)'
        @context.fillStyle = color
        @context.fillRect(x * @pixelSize, y * @pixelSize, @pixelSize, @pixelSize)

    @context.getPixel = (x,y) =>
      rgba = @context.getImageData(x * @pixelSize + 1, y * @pixelSize + 1, 1, 1).data

    @inDragMode = false
    @dragging = false
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
    @undoStack = []
    @redoStack = []

    @image.onload = () =>
      @prepareDataForDisplayedFrame()
      @render()
    @image.src = @dataURLRepresentation() if saveChanges
    @imageDisplayedFrame = index
    @prepareDataForDisplayedFrame()
    @render()


  stagePointToPixel: (x, y) ->
    new Point( Math.min( Math.round(x / @pixelSize), Tile.WIDTH ) , Math.min( Math.round(y / @pixelSize), Tile.HEIGHT ) ) 


  handleKeyEvent: (ev) =>
    if @inDragMode == true 
      if ev.keyCode == 13
          # copy drag data to the canvas.
          @applyPixelsFromDataIgnoreTransparent( @dragData.data, @imageData, 0, 0, Tile.WIDTH, Tile.HEIGHT, Tile.WIDTH, Math.floor(@dragData.offsetX / @pixelSize), Math.floor(@dragData.offsetY / @pixelSize) )
          @inDragMode = false

      @dragData.offsetY -= @pixelSize if ev.keyCode == 38
      @dragData.offsetY += @pixelSize if ev.keyCode == 40
      @dragData.offsetX -= @pixelSize if ev.keyCode == 37
      @dragData.offsetX += @pixelSize if ev.keyCode == 39
      @render()

    if ev.keyCode == 8 or ev.keyCode == 46
      return unless @selectedPixels
      @clearPixels( @selectedPixels )
      #@clearRect( @selectionRect.min.x, @selectionRect.min.y, @selectionRect.max.x, @selectionRect.max.y )
      @render()

    if ev.keyCode == 67 and ev.metaKey
      @copy()
    if ev.keyCode == 86 and ev.metaKey
      @paste()

    if ev.keyCode == 90 and ev.metaKey and ev.shiftKey
      @redo()
      window.rootScope.$apply()
    else if ev.keyCode == 90 and ev.metaKey
      @undo()
      window.rootScope.$apply()


  handleCanvasEvent: (ev) =>
    return unless @tool

    type = ev.type
    type = 'mouseup' if type == 'mouseout'

    if @inDragMode == false
      @tool[type](@stagePointToPixel(ev.offsetX, ev.offsetY))
      @applyTool() if type == 'mouseup' and @tool.autoApplyChanges == true
      @render()
    else
      if type == 'mousedown' and @dragging == false
        @dragging = true
        @dragStart.x = ev.offsetX - @dragData.offsetX
        @dragStart.y = ev.offsetY - @dragData.offsetY
      if type == 'mouseup'
        @dragging = false
      if type == 'mousemove' and @dragging == true
        @dragData.offsetX = Math.floor((ev.offsetX-@dragStart.x) / @pixelSize) * @pixelSize
        @dragData.offsetY = Math.floor((ev.offsetY-@dragStart.y) / @pixelSize) * @pixelSize

      @render()

  copy: () =>
    @clipboardData = new Uint8ClampedArray( Tile.WIDTH * Tile.HEIGHT * 4 )

    for p in @selectedPixels
      @clipboardData[ (p.y * Tile.WIDTH + p.x) * 4 + 0 ] = @imageData.data[ (p.y * Tile.WIDTH + p.x) * 4 + 0 ]
      @clipboardData[ (p.y * Tile.WIDTH + p.x) * 4 + 1 ] = @imageData.data[ (p.y * Tile.WIDTH + p.x) * 4 + 1 ]
      @clipboardData[ (p.y * Tile.WIDTH + p.x) * 4 + 2 ] = @imageData.data[ (p.y * Tile.WIDTH + p.x) * 4 + 2 ]
      @clipboardData[ (p.y * Tile.WIDTH + p.x) * 4 + 3 ] = @imageData.data[ (p.y * Tile.WIDTH + p.x) * 4 + 3 ]

    window.rootScope.$apply()

  paste: () =>
    return unless @clipboardData
    @dragData.clearRect( 0, 0, Tile.WIDTH, Tile.HEIGHT )
    @applyPixelsFromData( @clipboardData, @dragData, 0, 0, Tile.WIDTH, Tile.HEIGHT )
    @inDragMode = true
    @undoStack.push(new Uint8ClampedArray(@imageData.data))
    @redoStack = []
    @render()

  clearPixels: ( pixels ) =>
    @undoStack.push(new Uint8ClampedArray(@imageData.data))
    @redoStack = []
    for p in pixels
      @imageData.clearRect( p.x, p.y, p.x+1, p.y+1 )


  render: () ->
    @context.fillStyle = "rgb(255,255,255)"
    @context.clearRect(0,0, @width, @height)
    @context.drawTransparentPattern()

    @applyPixelsFromData(@imageData.data, @context)

    if @inDragMode == true
      # grey out all things not being dragged.
      @context.fillStyle = "rgba(0,0,0,0.3)"
      @context.fillRect( 0,0, @width, @height )

      # draw the drag buffer.
      @context.translate( @dragData.offsetX, @dragData.offsetY )
      @applyPixelsFromData(@dragData.data, @context, 0, 0, @dragData.width, @dragData.height, @dragData.width)
      @context.translate( -@dragData.offsetX, -@dragData.offsetY )

    @tool.render(@context, @) if @tool

      # draw selected pixels
    for p in @selectedPixels
      @context.fillPixel(p.x, p.y, "rgba(0, 0, 0, 0.2)")


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


  applyTool: () ->
    @undoStack.push(new Uint8ClampedArray(@imageData.data))
    @redoStack = []
    @tool.render(@imageData, @)
    @tool.reset()
    window.rootScope.$apply()


  applyPixelsFromData: (data, target, startX=0, startY=0, endX=Tile.WIDTH, endY=Tile.HEIGHT, dataWidth=Tile.WIDTH, offsetX = 0, offsetY = 0) ->
    for x in [startX..endX-1]
      for y in [startY..endY-1]
        r = data[(y * dataWidth + x) * 4 + 0]
        g = data[(y * dataWidth + x) * 4 + 1]
        b = data[(y * dataWidth + x) * 4 + 2]
        a = data[(y * dataWidth + x) * 4 + 3]
        target.fillPixel(x+offsetX,y+offsetY,"rgba(#{r},#{g},#{b},#{a})")

  applyPixelsFromDataIgnoreTransparent: (data, target, startX=0, startY=0, endX=Tile.WIDTH, endY=Tile.HEIGHT, dataWidth=Tile.WIDTH, offsetX = 0, offsetY = 0) ->
    for x in [startX..endX-1]
      for y in [startY..endY-1]
        r = data[(y * dataWidth + x) * 4 + 0]
        g = data[(y * dataWidth + x) * 4 + 1]
        b = data[(y * dataWidth + x) * 4 + 2]
        a = data[(y * dataWidth + x) * 4 + 3]
        target.fillPixel(x+offsetX,y+offsetY,"rgba(#{r},#{g},#{b},#{a})") if a > 0


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


  canCopy: () ->
    #return false if (@selectionRect.max.x - @selectionRect.min.x) == 0
    #return false if (@selectionRect.max.y - @selectionRect.min.y) == 0
    @selectedPixels.length

  canPaste: () ->
    return true if @clipboardData
    return false

  canUndo: () ->
    @undoStack.length


  undo: () ->
    return unless @canUndo()
    @redoStack.push(new Uint8ClampedArray(@imageData.data))
    @applyPixelsFromData(@undoStack.pop(), @imageData)
    @render()


  canRedo: () ->
    @redoStack.length


  redo: () ->
    return unless @canRedo()
    @undoStack.push(new Uint8ClampedArray(@imageData.data))
    @applyPixelsFromData(@redoStack.pop(), @imageData)
    @render()


  coordsForFrame: (frame) ->
    x = frame % (@image.width / Tile.WIDTH)
    y = Math.floor(frame / (@image.width / Tile.WIDTH))
    [x  * Tile.WIDTH, y * Tile.HEIGHT]


  dataURLRepresentation: () ->
    [x,y] = @coordsForFrame(@imageDisplayedFrame)

    totalWidth = Math.max(@image.width, x + Tile.WIDTH)
    totalHeight = Math.max(@image.height, y + Tile.HEIGHT)

    url = false
    @_withTempCanvas totalWidth, totalHeight, (canvas) =>
      context = canvas.getContext("2d")
      context.drawImage(@image, 0, 0) if @image
      context.putImageData(@imageData, x, y)
      url = canvas.toDataURL()

    {data: url, width: totalWidth}

  prepareDataForDisplayedFrame: () ->
    @_withTempCanvas Tile.WIDTH, Tile.HEIGHT, (canvas) =>
      [x, y] = @coordsForFrame(@imageDisplayedFrame)
      context = canvas.getContext("2d")
      context.imageSmoothingEnabled = false
      context.clearRect(0,0, @width, @height)
      context.drawImage(@image, -x, -y) if @image
      @imageData = context.getImageData(0, 0, canvas.width, canvas.height)
    @_extendImageData(@imageData)
    @imageData

    # this just restores all persistent stuff to its default values... FUN :D
  cleanup: () =>
    @inDragMode = false
    @dragging = false
    @dragData.clearRect( 0, 0, Tile.WIDTH, Tile.HEIGHT )
    @dragStart = {x:0, y:0}
    @selectedPixels = []
    @render()

  _extendImageData: (imgData) ->
    imgData.fillPixel = (xx, yy, color = @toolColor) =>
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


  _withTempCanvas: (w, h, func) ->
    canvas = document.createElement("canvas")
    canvas.width = w
    canvas.height = h
    document.body.appendChild(canvas)
    func(canvas)
    document.body.removeChild(canvas)



window.PixelArtCanvas = PixelArtCanvas