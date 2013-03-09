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