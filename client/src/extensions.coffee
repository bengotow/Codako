Math.createUUID = () ->
  return '_' + Math.floor((1 + Math.random()) * 0x10000).toString(6)

# Extracted from JavaScript The Good Part
Array.matrix = (m, n, initial) ->
  a = undefined
  i = undefined
  j = undefined
  mat = []
  i = 0
  while i < m
    a = []
    j = 0
    while j < n
      a[j] = initial
      j += 1
    mat[i] = a
    i += 1
  mat

Math.clamp = (value, min, max) ->
  value = (if value > max then max else value)
  value = (if value < min then min else value)
  value

Point.fromString = (str) ->
  components = str.split(',')
  return new Point(components[0]/1, components[1]/1)

Point.fromHash = (hash) ->
  new Point(hash.x, hash.y)

Point.isZero = (coord) ->
  coord.x == 0 && coord.y == 0

Point.sum = (a,b) ->
  new Point(a.x + b.x, a.y + b.y)

Point.dif = (a,b) ->
  new Point(a.x - b.x, a.y - b.y)

Point::isInside = (rect) ->
  rect.left <= @x && rect.top <= @y && rect.right >= @x && rect.bottom >= @y

Point::isEqual = (coord) ->
  coord.x == @x && coord.y == @y

window.hsvToRgb = (h, s, v) ->
    r = g = b = 0
    i = Math.floor(h * 6)
    f = h * 6 - i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)

    switch(i % 6)
        when 0
          r = v
          g = t
          b = p
        when 1
          r = q
          g = v
          b = p
        when 2
          r = p
          g = v
          b = t
        when 3
          r = p
          g = q
          b = v
        when 4
          r = t
          g = p
          b = v
        when 5
          r = v
          g = p
          b = q

    return [r * 255, g * 255, b * 255]


window.withTempCanvas = (w, h, func) ->
  canvas = document.createElement("canvas")
  canvas.width = w
  canvas.height = h
  document.body.appendChild(canvas)
  ret = func(canvas, canvas.getContext("2d"))
  document.body.removeChild(canvas)
  ret
