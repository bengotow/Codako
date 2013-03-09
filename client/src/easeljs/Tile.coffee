
class Enum
  @TileCollision =
    Passable: 0
    Impassable: 1
    Platform: 2

class Tile extends Bitmap
  constructor: (texture, collision, x, y) ->
    if texture?
      Tile.__super__.initialize.call(@, texture)
      @empty = false
    else
      @empty = true
    @Collision = collision
    @x = x * @Width
    @y = y * @Height

    Tile::Width = 40
    Tile::Height = 32
    @


window.Tile = Tile
window.Enum = Enum
