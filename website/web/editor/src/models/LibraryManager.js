(function() {
  var LibraryManager,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  LibraryManager = (function() {

    function LibraryManager(name, progressCallback) {
      this.addActorDefinition = __bind(this.addActorDefinition, this);

      this.createActorDefinition = __bind(this.createActorDefinition, this);

      this.loadActorDefinition = __bind(this.loadActorDefinition, this);

      this.loadActorDefinitions = __bind(this.loadActorDefinitions, this);
      this.libraryName = name;
      this.libraryProgressCallback = progressCallback;
      this.definitions = {};
      this;

    }

    LibraryManager.prototype.loadActorDefinitions = function(identifiers, callback) {
      if (!(identifiers && identifiers.length)) {
        return callback(null);
      }
      return async.each(identifiers, this.loadActorDefinition, callback);
    };

    LibraryManager.prototype.loadActorDefinition = function(identifier, callback) {
      var _this = this;
      if (this.definitions[identifier]) {
        return callback(null);
      }
      this.outstanding += 1;
      return $.ajax({
        url: "/api/v0/worlds/" + window.Game.world_id + "/actors/" + identifier
      }).done(function(json) {
        var actor;
        actor = new ActorDefinition(json);
        return _this.addActorDefinition(actor, callback);
      });
    };

    LibraryManager.prototype.createActorDefinition = function(callback) {
      var _this = this;
      return $.ajax({
        url: "/api/v0/worlds/" + window.Game.world_id + "/actors",
        type: "POST"
      }).done(function(json) {
        var actor;
        actor = new ActorDefinition(json);
        return _this.addActorDefinition(actor, callback);
      });
    };

    LibraryManager.prototype.addActorDefinition = function(actor, callback) {
      var _base,
        _this = this;
      if (callback == null) {
        callback = null;
      }
      actor.img = new Image();
      actor.img.src = "";
      $(actor.img).on('load', function() {
        var progress;
        $(actor.img).off('load');
        _this.outstanding -= 1;
        _this.definitions[actor._id] = actor;
        progress = (_this.definitions.length / (_this.definitions.length + _this.outstanding)) * 100;
        _this.libraryProgressCallback({
          progress: progress
        });
        if (callback) {
          return callback(actor);
        }
      });
      (_base = actor.spritesheet).data || (_base.data = './img/splat.png');
      actor.img.src = actor.spritesheet.data;
      return actor;
    };

    LibraryManager.prototype.instantiateActorFromDescriptor = function(descriptor, initial_position) {
      var constraint, def, model, pos, variable, _ref;
      if (initial_position == null) {
        initial_position = null;
      }
      def = this.definitions[descriptor._id];
      if (!def) {
        return false;
      }
      pos = new Point(-1, -1);
      if (descriptor.position) {
        pos = Point.fromHash(descriptor.position);
      }
      if (initial_position) {
        pos = initial_position;
      }
      model = new ActorSprite(ident, pos, def.size);
      model.setSpriteSheet(def.spritesheetInstance());
      model._id = descriptor._id || descriptor.actor_id_during_recording || Math.createUUID();
      model.definition = def;
      if (descriptor.variableValues) {
        model.variableValues = _.clone(descriptor.variableValues);
      } else if (descriptor.variableConstraints) {
        model.variableValues = {};
        _ref = descriptor.variableConstraints;
        for (variable in _ref) {
          constraint = _ref[variable];
          if (constraint.comparator === '=') {
            model.variableValues[variable] = constraint.value / 1;
          }
          if (constraint.comparator === '<') {
            model.variableValues[variable] = constraint.value / 1 - 1;
          }
          if (constraint.comparator === '>') {
            model.variableValues[variable] = constraint.value / 1 + 1;
          }
        }
      } else {
        model.variableValues || (model.variableValues = {});
      }
      model.setAppearance(descriptor.appearance);
      return model;
    };

    return LibraryManager;

  })();

  window.LibraryManager = LibraryManager;

}).call(this);
