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

Point::isEqual = (coord) ->
  coord.x == @x && coord.y == @y
