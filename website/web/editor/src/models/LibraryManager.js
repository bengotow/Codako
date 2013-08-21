(function() {
  var LibraryManager,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  LibraryManager = (function() {

    function LibraryManager(name, progressCallback) {
      this.addActorDefinition = __bind(this.addActorDefinition, this);

      this.loadActorDefinition = __bind(this.loadActorDefinition, this);

      this.loadActorDefinitions = __bind(this.loadActorDefinitions, this);

      var _this = this;
      this.libraryName = name;
      this.libraryProgressCallback = progressCallback;
      this.definitions = {};
      this.definitionReadyCallbacks = {};
      window.Socket.on('actor', function(actor_json) {
        var actor;
        actor = new ActorDefinition(actor_json);
        return _this.addActorDefinition(actor);
      });
      this;

    }

    LibraryManager.prototype.loadActorDefinitions = function(identifiers, callback) {
      if (!(identifiers && identifiers.length)) {
        return callback(null);
      }
      return async.each(identifiers, this.loadActorDefinition, callback);
    };

    LibraryManager.prototype.loadActorDefinition = function(identifier, callback) {
      if (this.definitions[identifier]) {
        return callback(null);
      }
      this.outstanding += 1;
      this.definitionReadyCallbacks[identifier] = callback;
      return window.Socket.emit('get-actor', {
        identifier: identifier
      });
    };

    LibraryManager.prototype.addActorDefinition = function(actor, readyCallback) {
      var _base,
        _this = this;
      if (readyCallback == null) {
        readyCallback = null;
      }
      actor.img = new Image();
      actor.img.onload = function() {
        var progress;
        _this.outstanding -= 1;
        _this.definitions[actor.identifier] = actor;
        progress = (_this.definitions.length / Object.keys(_this.definitionReadyCallbacks).length) * 100;
        _this.libraryProgressCallback({
          progress: progress
        });
        console.log('got actor identifier', actor.identifier);
        if (_this.definitionReadyCallbacks[actor.identifier]) {
          _this.definitionReadyCallbacks[actor.identifier](null);
        }
        if (readyCallback) {
          return readyCallback(null);
        }
      };
      (_base = actor.spritesheet).data || (_base.data = 'img/splat.png');
      return actor.img.src = actor.spritesheet.data;
    };

    LibraryManager.prototype.instantiateActorFromDescriptor = function(descriptor, initial_position) {
      var constraint, def, ident, model, pos, variable, _ref;
      if (initial_position == null) {
        initial_position = null;
      }
      ident = descriptor.identifier;
      def = this.definitions[ident];
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
