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

    LibraryManager.prototype.loadActorDefinitions = function(IDs, callback) {
      if (!(IDs && IDs.length)) {
        return callback(null);
      }
      return async.each(IDs, this.loadActorDefinition, callback);
    };

    LibraryManager.prototype.loadActorDefinition = function(ID, callback) {
      var _this = this;
      if (this.definitions[ID]) {
        return callback(null);
      }
      this.outstanding += 1;
      return $.ajax({
        url: "/api/v0/worlds/" + window.Game.world_id + "/actors/" + ID
      }).done(function(json) {
        var definition;
        definition = new ActorDefinition(json);
        return _this.addActorDefinition(definition, callback);
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

    LibraryManager.prototype.addActorDefinition = function(definition, callback) {
      var _base,
        _this = this;
      if (callback == null) {
        callback = null;
      }
      definition.img = new Image();
      definition.img.src = "";
      $(definition.img).on('load', function() {
        var progress;
        $(definition.img).off('load');
        _this.outstanding -= 1;
        _this.definitions[definition._id] = definition;
        progress = (_this.definitions.length / (_this.definitions.length + _this.outstanding)) * 100;
        _this.libraryProgressCallback({
          progress: progress
        });
        if (callback) {
          return callback(definition);
        }
      });
      (_base = definition.spritesheet).data || (_base.data = './img/splat.png');
      definition.img.src = definition.spritesheet.data;
      return definition;
    };

    LibraryManager.prototype.instantiateActorFromDescriptor = function(descriptor, initial_position) {
      var constraint, definition, model, pos, variable, _ref;
      if (initial_position == null) {
        initial_position = null;
      }
      definition = this.definitions[descriptor.definition_id];
      if (!definition) {
        return false;
      }
      pos = new Point(-1, -1);
      if (descriptor.position) {
        pos = Point.fromHash(descriptor.position);
      }
      if (initial_position) {
        pos = initial_position;
      }
      model = new ActorSprite(definition._id, pos, definition.size);
      model.setSpriteSheet(definition.spritesheetInstance());
      model._id = descriptor._id || descriptor.actor_id_during_recording || Math.createUUID();
      model.definition = definition;
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
