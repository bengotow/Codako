class SquareMaskSprite extends Sprite

  constructor: (type) ->
    super(new Point(1,1), {width:1, height:1}, null)
    @type = type
    @createSpriteSheet(window.Game.content.imageNamed("tile_#{type}"))


window.SquareMaskSprite = SquareMaskSprite