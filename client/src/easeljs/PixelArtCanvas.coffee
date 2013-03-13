
class PixelTool

  constructor: () ->
    @down = false
    @name = 'Undefined'
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

  mouseout: (point) ->
    @mouseup(point)

  render: (context) ->

  renderLine: (context,x0,y0,x1,y1) ->
    dx = Math.abs(x1 - x0)
    dy = Math.abs(y1 - y0)
    if x0 < x1 then sx = 1 else sx = -1
    if y0 < y1 then sy = 1 else sy = -1
    err = dx - dy

    while true
      context.fillPixel(x0,y0)
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


class PixelFillTool extends PixelTool

  constructor: () ->
    super
    @name = 'Fill'

  render: (context) ->
    return unless @s && @e
    for x in [@s.x..@e.x]
      for y in [@s.y..@e.y]
        context.fillPixel(x,y)


class PixelFillCircleTool extends PixelTool

  constructor: () ->
    super
    @name = 'Fill Circle'

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
    @name = 'Pen'

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
    @name = 'Line'

  render: (context) ->
    return unless @s && @e
    @renderLine(context, @s.x,@s.y,@e.x,@e.y)


class PixelArtCanvas

  constructor: (image, canvas, controller_scope) ->
    @controller = controller_scope
    @width = canvas.width
    @height = canvas.height
    @image = image
    @tools = [new PixelFreehandTool(), new PixelLineTool(), new PixelFillCircleTool(), new PixelFillTool()]
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

    # augment our context object
    @context = canvas.getContext("2d")
    @context.fillPixel = (x, y, color = @toolColor) =>
      @context.fillStyle = color
      @context.fillRect(x * @pixelSize, y * @pixelSize, @pixelSize, @pixelSize)

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
    new Point(Math.floor(x / @pixelSize), Math.floor(y / @pixelSize))


  handleCanvasEvent: (ev) =>
    return unless @tool
    ev._x = ev.offsetX
    ev._y = ev.offsetY
    @tool[ev.type](@stagePointToPixel(ev._x, ev._y))
    @applyTool() if ev.type == 'mouseup'
    @render()


  render: () ->
    @context.fillStyle = "rgb(255,255,255)"
    @context.fillRect(0,0, @width, @height)
    @applyPixelsFromData(@imageData.data, @context)
    @tool.render(@context) if @tool

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
    @tool.render(@imageData)
    @tool.reset()
    window.rootScope.$apply()


  applyPixelsFromData: (data, target) ->
    for x in [0..Tile.WIDTH+1]
      for y in [0..Tile.HEIGHT+1]
        r = data[(y * Tile.WIDTH + x) * 4 + 0]
        g = data[(y * Tile.WIDTH + x) * 4 + 1]
        b = data[(y * Tile.WIDTH + x) * 4 + 2]
        a = data[(y * Tile.WIDTH + x) * 4 + 3]
        target.fillPixel(x,y,"rgba(#{r},#{g},#{b},#{a})")


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
      context.fillStyle = "rgb(255,255,255)"
      context.fillRect(0,0, canvas.width, canvas.height)
      context.drawImage(@image, -x, -y) if @image
      @imageData = context.getImageData(0, 0, canvas.width, canvas.height)
      @imageData.fillPixel = (xx, yy, color = @toolColor) =>
        components = color[5..-2].split(',')
        for i in [0..components.length-1]
          @imageData.data[(yy * Tile.WIDTH + xx) * 4 + i] = components[i]/1
    @imageData


  _withTempCanvas: (w, h, func) ->
    canvas = document.createElement("canvas")
    canvas.width = w
    canvas.height = h
    document.body.appendChild(canvas)
    func(canvas)
    document.body.removeChild(canvas)



window.PixelArtCanvas = PixelArtCanvas