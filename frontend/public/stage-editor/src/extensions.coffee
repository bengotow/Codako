Math.createUUID = ->
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

String.fromEventKeyCode = (code) ->
  if code == 32
    return 'Space Bar'
  if code == 13
    return 'Enter'
  if code == 9
    return 'Tab'
  if code == 187
    return '+'
  if code == 189
    return '-'
  if code == 192
    return '`'
  if code == 188
    return '<'
  if code == 190
    return '>'
  if code == 191
    return '?'
  if code == 186
    return ';'
  if code == 222
    return '"'
  if code == 220
    return '\\'
  if code == 221
    return ']'
  if code == 219
    return '['
  else
    return String.fromCharCode(code)

Math.clamp = (value, min, max) ->
  value = (if value > max then max else value)
  value = (if value < min then min else value)
  value

Math.applyOperation = (existing, operation, value) ->
  return existing/1 + value/1 if operation == 'add'
  return existing/1 - value/1 if operation == 'subtract'
  return value/1 if operation == 'set'
  throw "Don't know how to apply operation #{existing}, #{operation}, #{value}"

Point.fromString = (str) ->
  components = str.split(',')
  return new Point(components[0]/1, components[1]/1)

Point.fromHash = (hash) ->
  if hash.x == undefined
    throw "Attempt to convert from hash to Point when source is not a hash: #{hash}"
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
