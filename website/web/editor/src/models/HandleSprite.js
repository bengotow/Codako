(function() {
  var HandleSprite,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HandleSprite = (function(_super) {

    __extends(HandleSprite, _super);

    function HandleSprite(side, extent) {
      var _this = this;
      HandleSprite.__super__.constructor.call(this, new Point(0, 0), {
        width: 1,
        height: 1
      }, null);
      this.side = side;
      this.createSpriteSheet(window.Game.content.imageNamed("handle_" + side));
      this.dragging = false;
      this.addEventListener('mousedown', function(e) {
        var grabX, grabY;
        grabX = e.stageX - _this.x;
        grabY = e.stageY - _this.y;
        _this.dragging = true;
        e.addEventListener('mousemove', function(e) {
          var p;
          p = new Point(Math.round((e.stageX - grabX) / Tile.WIDTH), Math.round((e.stageY - grabY) / Tile.HEIGHT));
          if (_this.worldPos.x !== p.x || _this.worldPos.y !== p.y) {
            _this.setWorldPos(p);
            return window.Game.recordingHandleDragged(_this, false);
          }
        });
        return e.addEventListener('mouseup', function(e) {
          _this.dragging = false;
          _this.setWorldPos(Math.round((e.stageX - grabX) / Tile.WIDTH), Math.round((e.stageY - grabY) / Tile.HEIGHT));
          return window.Game.recordingHandleDragged(_this, true);
        });
      });
      this.positionWithExtent(extent);
      this;

    }

    HandleSprite.prototype.positionWithExtent = function(extent) {
      if (this.side === 'left') {
        this.setWorldPos(extent.left - 1, extent.top + (extent.bottom - extent.top) / 2);
      } else if (this.side === 'right') {
        this.setWorldPos(extent.right + 1, extent.top + (extent.bottom - extent.top) / 2);
      } else if (this.side === 'top') {
        this.setWorldPos((extent.right + extent.left) / 2, extent.top - 1);
      } else {
        this.setWorldPos((extent.right + extent.left) / 2, extent.bottom + 1);
      }
      return this.tick(0);
    };

    return HandleSprite;

  })(Sprite);

  window.HandleSprite = HandleSprite;

}).call(this);
