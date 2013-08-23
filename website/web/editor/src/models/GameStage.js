(function() {
  var GameStage,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  GameStage = (function(_super) {

    __extends(GameStage, _super);

    function GameStage(canvas) {
      this.setStatusMessage = __bind(this.setStatusMessage, this);

      this.setBackground = __bind(this.setBackground, this);

      this.dispose = __bind(this.dispose, this);

      var _this = this;
      GameStage.__super__.initialize.call(this, canvas);
      this._id = null;
      this.background = null;
      this.backgroundSprite = null;
      this.recordingHandles = {};
      this.recordingMasks = [];
      this.recordingMaskStyle = 'masked';
      this.recordingExtent = {};
      this.recordingCentered = false;
      this.offsetTarget = new Point(0, 0);
      this.statusMessage = null;
      this.draggingEnabled = true;
      this.actors = [];
      this.width = 20;
      this.height = 20;
      this.wrapX = true;
      this.wrapY = true;
      this.widthTarget = canvas.width;
      this.widthCurrent = canvas.width;
      this.canvas.ondrop = function(e, dragEl) {
        var actor, dragIdentifier, parentOffset, point;
        dragIdentifier = $(dragEl.draggable).data('identifier');
        parentOffset = $(_this.canvas).parent().offset();
        e.pageX = e.pageX - _this.x - $(_this.canvas).offset().left;
        e.pageY = e.pageY - _this.y;
        point = new Point(Math.round((e.pageX - e.offsetX) / Tile.WIDTH), Math.round((e.pageY - e.offsetY - parentOffset.top) / Tile.HEIGHT));
        if (dragIdentifier.slice(0, 5) === 'actor') {
          actor = _this.addActor({
            definition_id: dragIdentifier.slice(6),
            position: point
          });
          return window.Game.onActorPlaced(actor, _this);
        } else if (dragIdentifier.slice(0, 10) === 'appearance') {
          actor = _this.actorsAtPosition(point)[0];
          if (actor) {
            return window.Game.onAppearancePlaced(actor, _this, dragIdentifier.slice(11));
          }
        }
      };
    }

    GameStage.prototype.onscreen = function() {
      return this.widthTarget > 1 || this.widthCurrent > 1;
    };

    GameStage.prototype.setDisplayWidth = function(width) {
      return this.widthTarget = width;
    };

    GameStage.prototype.saveData = function(options) {
      var actor, data, _i, _len, _ref;
      if (options == null) {
        options = {};
      }
      data = {
        _id: this._id,
        width: this.width,
        height: this.height,
        wrapX: this.wrapX,
        wrapY: this.wrapY,
        background: this.background,
        actor_library: window.Game.library.actorDefinitionIDs(),
        actor_descriptors: []
      };
      if (options.thumbnail) {
        data.thumbnail = this.canvas.toDataURL("image/jpeg", 0.8);
      }
      _ref = this.actors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        data.actor_descriptors.push(actor.descriptor());
      }
      return data;
    };

    GameStage.prototype.prepareWithData = function(json, callback) {
      var actor, library, _i, _len, _ref,
        _this = this;
      this.dispose();
      this.width = json['width'];
      this.height = json['height'];
      this.wrapX = json['wrapX'];
      this.wrapY = json['wrapY'];
      this.setBackground(json['background']);
      library = json.actor_library || [];
      _ref = json.actor_descriptors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        if (library.indexOf(actor.definition_id) === -1) {
          library.push(actor.definition_id);
        }
      }
      return window.Game.library.loadActorDefinitions(library, function(err) {
        var descriptor, _j, _len1, _ref1;
        _ref1 = json.actor_descriptors;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          descriptor = _ref1[_j];
          _this.addActor(descriptor);
        }
        _this.update();
        if (callback) {
          return callback(null);
        }
      });
    };

    GameStage.prototype.dispose = function() {
      this.actors = [];
      this.recordingMasks = [];
      this.recordingHandles = {};
      this.removeAllChildren();
      return this.update();
    };

    GameStage.prototype.setBackground = function(background, animate) {
      var img,
        _this = this;
      if (animate == null) {
        animate = false;
      }
      this.background = background || '/editor/img/backgrounds/Layer0_2.png';
      img = new Image();
      img.crossOrigin = 'Anonymous';
      img.src = '';
      $(img).on('load', function() {
        var scale;
        $(img).off('load');
        if (_this.backgroundSprite) {
          _this.removeChild(_this.backgroundSprite);
        }
        _this.backgroundSprite = new Bitmap(img);
        scale = Math.max((_this.width * Tile.WIDTH) / img.width, (_this.height * Tile.HEIGHT) / img.height);
        _this.backgroundSprite.scaleX = _this.backgroundSprite.scaleY = scale;
        _this.backgroundSprite.addEventListener('click', function(e) {
          return window.Game.onActorClicked(null);
        });
        _this.backgroundSprite.addEventListener('dblclick', function(e) {
          return window.Game.onActorDoubleClicked(null);
        });
        return _this.addChildAt(_this.backgroundSprite, 0);
      });
      if (this.background.indexOf('/') !== -1) {
        return img.src = this.background;
      } else {
        return img.src = "//cocoa-user-assets.s3-website-us-east-1.amazonaws.com/" + this.background;
      }
    };

    GameStage.prototype.setStatusMessage = function(message) {
      if (message) {
        if (!this.statusMessage) {
          this.statusMessage = new Text("-- %", "bold 14px Arial", "#FFF");
          this.statusMessage.x = (this.width / 2) - 50;
          this.statusMessage.y = this.height / 2;
          this.addChild(this.statusMessage);
        }
        this.statusMessage.text = message;
        return this.update();
      } else {
        this.removeChild(this.statusMessage);
        return this.statusMessage = null;
      }
    };

    GameStage.prototype.setRecordingExtent = function(extent, maskStyle) {
      var i, key, obj, side, sprite, styleChanged, usedMasks, x, y, _i, _j, _k, _l, _len, _ref, _ref1, _ref2, _ref3, _ref4;
      if (maskStyle == null) {
        maskStyle = this.recordingMaskStyle;
      }
      styleChanged = maskStyle !== this.recordingMaskStyle;
      if (styleChanged) {
        this.setRecordingExtent(null);
      }
      this.recordingMaskStyle = maskStyle;
      this.recordingExtent = extent;
      _ref = this.recordingHandles;
      for (key in _ref) {
        obj = _ref[key];
        this.removeChild(obj);
      }
      this.recordingHandles = {};
      usedMasks = 0;
      for (x = _i = 0, _ref1 = this.width; 0 <= _ref1 ? _i <= _ref1 : _i >= _ref1; x = 0 <= _ref1 ? ++_i : --_i) {
        for (y = _j = 0, _ref2 = this.height; 0 <= _ref2 ? _j <= _ref2 : _j >= _ref2; y = 0 <= _ref2 ? ++_j : --_j) {
          if (extent && ((x < extent.left || x > extent.right) || (y < extent.top || y > extent.bottom))) {
            if (usedMasks < this.recordingMasks.length) {
              sprite = this.recordingMasks[usedMasks];
            } else {
              sprite = new SquareMaskSprite(this.recordingMaskStyle);
              this.addChild(sprite);
              this.recordingMasks.push(sprite);
            }
            sprite.x = x * Tile.WIDTH;
            sprite.y = y * Tile.HEIGHT;
            usedMasks += 1;
          }
        }
      }
      if (usedMasks < this.recordingMasks.length) {
        for (i = _k = usedMasks, _ref3 = this.recordingMasks.length - 1; usedMasks <= _ref3 ? _k <= _ref3 : _k >= _ref3; i = usedMasks <= _ref3 ? ++_k : --_k) {
          this.removeChild(this.recordingMasks[i]);
        }
      }
      this.recordingMasks = this.recordingMasks.slice(0, usedMasks);
      if (!extent) {
        return;
      }
      _ref4 = ['top', 'left', 'right', 'bottom'];
      for (_l = 0, _len = _ref4.length; _l < _len; _l++) {
        side = _ref4[_l];
        this.recordingHandles[side] = new HandleSprite(side, extent);
        this.recordingHandles[side].positionWithExtent(extent);
        this.addChild(this.recordingHandles[side]);
      }
      if (this.recordingCentered) {
        return this.centerOnRecordingRegion();
      }
    };

    GameStage.prototype.clearRecording = function() {
      this.setRecordingCentered(false);
      this.setRecordingExtent(null);
      this.centerOnEntireCanvas();
      return this.draggingEnabled = true;
    };

    GameStage.prototype.setRecordingCentered = function(centered) {
      this.recordingCentered = centered;
      if (this.recordingCentered) {
        this.centerOnRecordingRegion();
      }
      return this.update();
    };

    GameStage.prototype.centerOnRecordingRegion = function() {
      if (this.recordingExtent) {
        this.offsetTarget.x = (4.5 - this.recordingExtent.left - (this.recordingExtent.right - this.recordingExtent.left) / 2) * Tile.WIDTH;
        return this.offsetTarget.y = (4 - this.recordingExtent.top - (this.recordingExtent.bottom - this.recordingExtent.top) / 2) * Tile.HEIGHT;
      }
    };

    GameStage.prototype.centerOnEntireCanvas = function() {
      return this.offsetTarget.x = this.offsetTarget.y = 0;
    };

    GameStage.prototype.update = function(elapsed) {
      var actor, _i, _len, _ref;
      this.widthCurrent = this.widthCurrent + (this.widthTarget - this.widthCurrent) / 15.0;
      if (this.canvas.width !== Math.round(this.widthCurrent)) {
        this.canvas.width = Math.round(this.widthCurrent);
      }
      GameStage.__super__.update.apply(this, arguments);
      _ref = this.actors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        actor.tick(elapsed);
      }
      this.x += (this.offsetTarget.x - this.x) / 15;
      return this.y += (this.offsetTarget.y - this.y) / 15;
    };

    GameStage.prototype.wrappedPosition = function(pos) {
      if (this.wrapX) {
        pos.x = (pos.x + this.width) % this.width;
      }
      if (this.wrapY) {
        pos.y = (pos.y + this.height) % this.height;
      }
      return pos;
    };

    GameStage.prototype.addActor = function(descriptor, pointIfNotInDescriptor) {
      var actor,
        _this = this;
      if (pointIfNotInDescriptor == null) {
        pointIfNotInDescriptor = null;
      }
      actor = window.Game.library.instantiateActorFromDescriptor(descriptor, pointIfNotInDescriptor);
      if (!actor) {
        return console.log('Could not read descriptor:', descriptor);
      }
      actor.addEventListener('click', function(e) {
        return window.Game.onActorClicked(actor);
      });
      actor.addEventListener('dblclick', function(e) {
        return window.Game.onActorDoubleClicked(actor);
      });
      actor.stage = this;
      actor.tick(0);
      this.actors.push(actor);
      this.addChild(actor);
      return actor;
    };

    GameStage.prototype.isDescriptorValid = function(descriptor) {
      return this.actorMatchingDescriptor(descriptor) != null;
    };

    GameStage.prototype.actorsAtPosition = function(position) {
      var actor, results, _i, _len, _ref;
      position = this.wrappedPosition(position);
      if (position.x < 0 || position.y < 0 || position.x >= this.width || position.y >= this.height) {
        return null;
      }
      results = [];
      _ref = this.actors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        if (actor.worldPos.isEqual(position)) {
          results.push(actor);
        }
      }
      return results;
    };

    GameStage.prototype.actorsAtPositionMatchDescriptors = function(position, descriptors) {
      var actor, descriptor, matched, searchSet, _i, _j, _len, _len1;
      searchSet = this.actorsAtPosition(position);
      if (searchSet === null) {
        return false;
      }
      if (searchSet.length === 0 && (!descriptors || descriptors.length === 0)) {
        return true;
      }
      if (searchSet.length !== descriptors.length) {
        return false;
      }
      for (_i = 0, _len = searchSet.length; _i < _len; _i++) {
        actor = searchSet[_i];
        matched = false;
        for (_j = 0, _len1 = descriptors.length; _j < _len1; _j++) {
          descriptor = descriptors[_j];
          if (actor.matchesDescriptor(descriptor)) {
            matched = true;
          }
        }
        if (!matched) {
          return false;
        }
      }
      return true;
    };

    GameStage.prototype.actorWithID = function(id, set) {
      var actor, results, _i, _len;
      if (set == null) {
        set = this.actors;
      }
      results = [];
      for (_i = 0, _len = set.length; _i < _len; _i++) {
        actor = set[_i];
        if (actor._id === id) {
          results.push(actor);
        }
      }
      if (results.length > 1) {
        console.log("There are multiple actors with the same ID!", results);
      }
      return results[0];
    };

    GameStage.prototype.actorMatchingDescriptor = function(descriptor, set) {
      var actor, _i, _len;
      if (set == null) {
        set = this.actors;
      }
      for (_i = 0, _len = set.length; _i < _len; _i++) {
        actor = set[_i];
        if (actor.matchesDescriptor(descriptor)) {
          return actor;
        }
      }
      return false;
    };

    GameStage.prototype.removeActor = function(index_or_actor) {
      if (index_or_actor instanceof Sprite) {
        this.removeChild(index_or_actor);
        return this.actors.splice(this.actors.indexOf(index_or_actor), 1);
      } else {
        this.removeChild(this.actors[index_or_actor]);
        return this.actors.splice(index_or_actor, 1);
      }
    };

    GameStage.prototype.removeActorsMatchingDescriptor = function(descriptor) {
      var x, _i, _ref, _results;
      _results = [];
      for (x = _i = _ref = this.actors.length - 1; _i >= 0; x = _i += -1) {
        if (this.actors[x].matchesDescriptor(descriptor)) {
          _results.push(this.removeActor(x));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return GameStage;

  })(Stage);

  window.GameStage = GameStage;

}).call(this);
