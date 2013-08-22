(function() {
  var Sprite,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Sprite = (function(_super) {

    __extends(Sprite, _super);

    function Sprite(position, size) {
      var graphics;
      this.worldPos = position;
      this.previousPos = position;
      this.worldSize = size;
      this.elapsed = 0;
      this.selected = false;
      graphics = new createjs.Graphics().beginFill("#ff0000").drawRect(0, 0, Tile.HEIGHT, Tile.WIDTH);
      this.hitArea = new createjs.Shape(graphics);
    }

    Sprite.prototype.setSpriteSheet = function(sheet) {
      Sprite.__super__.initialize.call(this, sheet);
      return this.gotoAndStop(0);
    };

    Sprite.prototype.createSpriteSheet = function(image, animations) {
      var sheet;
      if (animations == null) {
        animations = {
          idle: [0, 0]
        };
      }
      sheet = new SpriteSheet({
        images: [image],
        animations: animations,
        frames: {
          width: Tile.WIDTH * this.worldSize.width,
          height: Tile.HEIGHT * this.worldSize.height,
          regX: 0,
          regY: 0
        }
      });
      SpriteSheetUtils.addFlippedFrames(sheet, true, false, false);
      return this.setSpriteSheet(sheet);
    };

    Sprite.prototype.tick = function(elapsed) {
      this.previousPos = null;
      this.x = this.worldPos.x * Tile.WIDTH;
      this.y = this.worldPos.y * Tile.HEIGHT;
      return this;
    };

    Sprite.prototype.setWorldPos = function(p_or_x, y) {
      if (y == null) {
        y = void 0;
      }
      this.previousPos || (this.previousPos = this.worldPos);
      if (y === void 0) {
        return this.worldPos = new Point(p_or_x.x, p_or_x.y);
      } else {
        return this.worldPos = new Point(p_or_x, y);
      }
    };

    Sprite.prototype.setSelected = function(sel) {
      this.selected = sel;
      this.filters = [];
      this.uncache();
      if (this.selected) {
        this.filters = [new createjs.SelectionFilter(2)];
        return this.cache(-2, -2, Tile.WIDTH + 4, Tile.HEIGHT + 4);
      }
    };

    Sprite.prototype.getBounds = function() {
      return Sprite.__super__.getBounds.apply(this, arguments);
    };

    Sprite.prototype.getWorldBounds = function() {
      return new XNARectangle(this.worldPos.x, this.worldPos.y, this.worldSize.width, this.worldSize.height);
    };

    Sprite.prototype.intersects = function(otherSprite) {
      return false;
    };

    return Sprite;

  })(BitmapAnimation);

  window.Sprite = Sprite;

}).call(this);
