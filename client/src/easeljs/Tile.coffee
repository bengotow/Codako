
Enum = ->

Enum.TileCollision =
  Passable: 0
  Impassable: 1
  Platform: 2

Tile = (texture, collision, x, y) ->
    @initialize(texture, collision, x, y)

Tile:: = new Bitmap()

# constructor:
Tile::Bitmap_initialize = Tile::initialize #unique to avoid overiding base class
Tile::initialize = (texture, collision, x, y) ->
    if texture?
      @Bitmap_initialize texture
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
