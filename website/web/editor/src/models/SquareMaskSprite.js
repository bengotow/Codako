(function() {
  var SquareMaskSprite,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  SquareMaskSprite = (function(_super) {

    __extends(SquareMaskSprite, _super);

    function SquareMaskSprite(type) {
      SquareMaskSprite.__super__.constructor.call(this, new Point(1, 1), {
        width: 1,
        height: 1
      }, null);
      this.type = type;
      this.createSpriteSheet(window.Game.content.imageNamed("tile_" + type));
    }

    return SquareMaskSprite;

  })(Sprite);

  window.SquareMaskSprite = SquareMaskSprite;

}).call(this);
