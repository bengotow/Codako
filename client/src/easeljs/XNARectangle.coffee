
class XNARectangle extends Rectangle

  constructor: (x, y, width, height) ->
    XNARectangle.__super__.initialize.call(@, x, y, width, height)
    @Location = new Point(@x, @y)
    @Center = new Point(parseInt(@x + @width / 2), parseInt(@y + @height / 2))
    @

  Left: ->
    parseInt @x

  Right: ->
    parseInt @x + @width

  Top: ->
    parseInt @y

  Bottom: ->
    parseInt @y + @height


  # Checking if the targetted rectangle is contained in this rectangle
  Contains: (targetRectangle) ->
    if @x <= targetRectangle.x and targetRectangle.x + targetRectangle.width <= @x + @width and @y <= targetRectangle.y
      targetRectangle.y + targetRectangle.height <= @y + @height
    else
      false


  # Checking if the targetted point is contained in this rectangle
  ContainsPoint: (targetPoint) ->
    if @x <= targetPoint.x and targetPoint.x < @x + @width and @y <= targetPoint.y
      targetPoint.y < @y + @height
    else
      false


  # Checking if the targetted rectangle intersects with this rectangle
  Intersects: (targetRectangle) ->
    if targetRectangle.x < @x + @width and @x < targetRectangle.x + targetRectangle.width and targetRectangle.y < @y + @height
      @y < targetRectangle.y + targetRectangle.height
    else
      false


  #/ <summary>
  #/ Gets the position of the center of the bottom edge of the rectangle.
  #/ </summary>
  GetBottomCenter: ->
    new Point(parseInt(@x + (@width / 2)), @Bottom())


  #/ <summary>
  #/ Calculates the signed depth of intersection between two rectangles.
  #/ </summary>
  #/ <returns>
  #/ The amount of overlap between two intersecting rectangles. These
  #/ depth values can be negative depending on which wides the rectangles
  #/ intersect. This allows callers to determine the correct direction
  #/ to push objects in order to resolve collisions.
  #/ If the rectangles are not intersecting, Vector2.Zero is returned.
  #/ </returns>
  GetIntersectionDepth: (rectB) ->
    rectA = this

    # Calculate half sizes.
    halfWidthA = rectA.width / 2.0
    halfHeightA = rectA.height / 2.0
    halfWidthB = rectB.width / 2.0
    halfHeightB = rectB.height / 2.0

    # Calculate centers.
    centerA = new Point(rectA.Left() + halfWidthA, rectA.Top() + halfHeightA)
    centerB = new Point(rectB.Left() + halfWidthB, rectB.Top() + halfHeightB)

    # Calculate current and minimum-non-intersecting distances between centers.
    distanceX = centerA.x - centerB.x
    distanceY = centerA.y - centerB.y
    minDistanceX = halfWidthA + halfWidthB
    minDistanceY = halfHeightA + halfHeightB

    # If we are not intersecting at all, return (0, 0).
    return new Point(0, 0)  if Math.abs(distanceX) >= minDistanceX or Math.abs(distanceY) >= minDistanceY

    # Calculate and return intersection depths.
    depthX = (if distanceX > 0 then minDistanceX - distanceX else -minDistanceX - distanceX)
    depthY = (if distanceY > 0 then minDistanceY - distanceY else -minDistanceY - distanceY)
    new Point(depthX, depthY)

  window.XNARectangle = XNARectangle