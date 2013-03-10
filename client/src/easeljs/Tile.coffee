
class Enum
  @TileCollision =
    Passable: 0
    Impassable: 1
    Platform: 2

class Tile extends Bitmap
  @WIDTH = 40
  @HEIGHT = 40

  constructor: (texture, collision, x, y) ->
    if texture?
      Tile.__super__.initialize.call(@, texture)
      @empty = false
    else
      @empty = true

    @Collision = collision
    @x = x * Tile.WIDTH
    @y = y * Tile.HEIGHT
    @


window.Tile = Tile
window.Enum = Enum
