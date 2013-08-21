(function() {
  var ActorDefinition,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  ActorDefinition = (function() {

    function ActorDefinition(json) {
      var key, value, _base, _base1;
      if (json == null) {
        json = {};
      }
      this.save = __bind(this.save, this);

      this.name = 'Untitled';
      this.identifier = Math.createUUID();
      this.variableDefaults = {};
      this.size = {
        width: 1,
        height: 1
      };
      this.spritesheet = {
        data: void 0,
        animations: {
          idle: [0, 0]
        },
        animation_names: {
          idle: 'Idle'
        }
      };
      this.spritesheetObj = null;
      this.spritesheetIconCache = {};
      this.img = null;
      for (key in json) {
        value = json[key];
        this[key] = value;
      }
      (_base = this.spritesheet).width || (_base.width = Tile.WIDTH);
      (_base1 = this.spritesheet).animation_names || (_base1.animation_names = {});
      this.rules = Rule.inflateRules(json['rules']);
      this.ruleRenderCache = {};
      this;

    }

    ActorDefinition.prototype.spritesheetInstance = function() {
      if (this.spritesheetObj) {
        return this.spritesheetObj;
      }
      this.spritesheetObj = new SpriteSheet({
        images: [this.img],
        animations: this.spritesheet.animations,
        frames: {
          width: Tile.WIDTH * this.size.width,
          height: Tile.HEIGHT * this.size.height,
          regX: 0,
          regY: 0
        }
      });
      SpriteSheetUtils.addFlippedFrames(this.spritesheetObj, true, false, false);
      return this.spritesheetObj;
    };

    ActorDefinition.prototype.iconForAppearance = function(appearance, width, height) {
      var key,
        _this = this;
      if (!(appearance && width > 0 && height > 0)) {
        return null;
      }
      key = "" + appearance + ":" + width + ":" + height;
      if (this.spritesheetIconCache[key]) {
        return this.spritesheetIconCache[key];
      }
      window.withTempCanvas(width, height, function(canvas, context) {
        var frame, spritesheet;
        spritesheet = _this.spritesheetInstance();
        frame = spritesheet.getFrame(spritesheet.getAnimation(appearance).frames[0]);
        context.drawImage(frame.image, frame.rect.x, frame.rect.y, frame.rect.width, frame.rect.height, 0, 0, width, height);
        return _this.spritesheetIconCache[key] = canvas.toDataURL();
      });
      return this.spritesheetIconCache[key];
    };

    ActorDefinition.prototype.rebuildSpritesheetInstance = function() {
      var key, old, value, _ref;
      old = this.spritesheetObj;
      this.spritesheetObj = null;
      this.spritesheetIconCache = {};
      this.spritesheetInstance();
      _ref = this.spritesheetObj;
      for (key in _ref) {
        value = _ref[key];
        old[key] = value;
      }
      return this.spritesheetObj = old;
    };

    ActorDefinition.prototype.save = function() {
      var json;
      json = {
        identifier: this.identifier,
        name: this.name,
        spritesheet: this.spritesheet,
        variableDefaults: this.variableDefaults,
        rules: Rule.deflateRules(this.rules)
      };
      return $.ajax({
        url: "/worlds/" + window.Game.world_id + "/actors/" + this.identifier + "/data",
        data: json,
        type: 'POST'
      }).done(function() {
        return console.log('Actor Saved');
      });
    };

    ActorDefinition.prototype.updateImageData = function(args) {
      var _this = this;
      if (args == null) {
        args = {
          data: null,
          width: 0
        };
      }
      this.spritesheet.data = args.data;
      this.spritesheet.width = args.width;
      this.img.src = args.data;
      return setTimeout(function() {
        _this.rebuildSpritesheetInstance();
        _this.ruleRenderCache = {};
        return window.rootScope.$apply();
      }, 250);
    };

    ActorDefinition.prototype.xywhForSpritesheetFrame = function(frame) {
      var perLine, x, y;
      perLine = this.spritesheet.width / (this.size.width * Tile.WIDTH);
      x = frame % perLine;
      y = Math.floor(frame / perLine);
      return [x * Tile.WIDTH, y * Tile.HEIGHT, this.size.width * Tile.WIDTH, this.size.height * Tile.HEIGHT];
    };

    ActorDefinition.prototype.frameForAppearance = function(identifier, index) {
      if (index == null) {
        index = 0;
      }
      return this.spritesheet.animations[identifier][index];
    };

    ActorDefinition.prototype.hasAppearance = function(identifier) {
      return this.spritesheet.animations[identifier] !== null;
    };

    ActorDefinition.prototype.nameForAppearance = function(identifier) {
      return this.spritesheet.animation_names[identifier] || 'Untitled';
    };

    ActorDefinition.prototype.renameAppearance = function(identifier, newname) {
      return this.spritesheet.animation_names[identifier] = newname;
    };

    ActorDefinition.prototype.addAppearance = function(name) {
      var animationCount, framesWide, identifier, index;
      if (name == null) {
        name = 'Untitled';
      }
      identifier = Math.createUUID();
      animationCount = Object.keys(this.spritesheet.animations).length;
      framesWide = this.img.width / (Tile.WIDTH * this.size.width);
      index = framesWide * animationCount;
      this.spritesheet.animations[identifier] = [index];
      this.spritesheet.animation_names[identifier] = name;
      return identifier;
    };

    ActorDefinition.prototype.deleteAppearance = function(identifier) {
      return delete this.spritesheet.animations[identifier];
    };

    ActorDefinition.prototype.addRule = function(rule) {
      var existing, idle_group, _i, _len, _ref;
      console.log("Adding Rule " + rule._id);
      if (this.findRule(rule)) {
        return;
      }
      idle_group = false;
      _ref = this.rules;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        existing = _ref[_i];
        if (existing.type === 'group-event' && existing.event === 'idle') {
          idle_group = existing;
        }
      }
      if (idle_group) {
        idle_group.rules.splice(0, 0, rule);
      } else {
        this.rules.splice(0, 0, rule);
      }
      return this.save();
    };

    ActorDefinition.prototype.findRule = function(rule, foundCallback, searchRoot) {
      var found, ii, _i, _ref;
      if (foundCallback == null) {
        foundCallback = null;
      }
      if (searchRoot == null) {
        searchRoot = this.rules;
      }
      for (ii = _i = 0, _ref = searchRoot.length - 1; _i <= _ref; ii = _i += 1) {
        if (searchRoot[ii]._id === rule._id) {
          if (foundCallback) {
            foundCallback(searchRoot, ii);
          }
          return true;
        }
        if (searchRoot[ii].rules) {
          found = this.findRule(rule, foundCallback, searchRoot[ii].rules);
          if (found) {
            return true;
          }
        }
      }
      return false;
    };

    ActorDefinition.prototype.clearCacheForRule = function(rule) {
      this.ruleRenderCache["" + rule._id + "-before"] = null;
      return this.ruleRenderCache["" + rule._id + "-after"] = null;
    };

    ActorDefinition.prototype.removeRule = function(rule) {
      var _this = this;
      return this.findRule(rule, function(collection, index) {
        collection.splice(index, 1);
        return _this.save();
      });
    };

    ActorDefinition.prototype.addEventGroup = function(config) {
      var existing, has_events, idle_group, new_group, _i, _len, _ref;
      if (config == null) {
        config = {
          event: 'key',
          code: '36'
        };
      }
      has_events = false;
      _ref = this.rules;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        existing = _ref[_i];
        if (existing.type === 'group-event') {
          has_events = true;
        }
      }
      if (!has_events) {
        idle_group = new EventGroupRule();
        idle_group.rules = idle_group.rules.concat(this.rules);
        this.rules = [idle_group];
      }
      new_group = new EventGroupRule();
      new_group.event = config.event;
      new_group.code = config.code;
      this.rules.splice(0, 0, new_group);
      return this.save();
    };

    ActorDefinition.prototype.addFlowGroup = function() {
      this.addRule(new FlowGroupRule());
      return this.save();
    };

    ActorDefinition.prototype.variables = function() {
      return this.variableDefaults;
    };

    ActorDefinition.prototype.variableIDs = function() {
      return _.map(this.variableDefaults, function(item) {
        return item._id;
      });
    };

    ActorDefinition.prototype.addVariable = function() {
      var newID;
      newID = Math.createUUID();
      return this.variableDefaults[newID] = {
        _id: newID,
        name: 'Untited',
        value: 0
      };
    };

    ActorDefinition.prototype.removeVariable = function(variable) {
      return delete this.variableDefaults[variable._id];
    };

    return ActorDefinition;

  })();

  window.ActorDefinition = ActorDefinition;

}).call(this);
