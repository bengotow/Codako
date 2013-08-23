(function() {
  var Rule,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Rule = (function() {

    function Rule(json) {
      this.withEachActorInExtent = __bind(this.withEachActorInExtent, this);

      this.actionFor = __bind(this.actionFor, this);

      this.scenarioOffsetOf = __bind(this.scenarioOffsetOf, this);

      this.descriptorsInScenario = __bind(this.descriptorsInScenario, this);

      this.descriptors = __bind(this.descriptors, this);

      this.descriptor = __bind(this.descriptor, this);

      this.extentOnStage = __bind(this.extentOnStage, this);

      this.extentRelativeToRoot = __bind(this.extentRelativeToRoot, this);

      this.updateActions = __bind(this.updateActions, this);

      this.updateScenario = __bind(this.updateScenario, this);

      var key, value;
      this._id = Math.createUUID();
      this.name = 'Untitled Rule';
      this.scenario = [];
      this.descriptors = {};
      this.actions = [];
      this.editing = false;
      for (key in json) {
        value = json[key];
        this[key] = value;
      }
      this.extentRoot = new Point(0, 0);
    }

    Rule.prototype.setMainActor = function(actor) {
      this.extentRoot = new Point(actor.worldPos.x, actor.worldPos.y);
      return this.actor = actor;
    };

    Rule.prototype.mainActorDescriptor = function() {
      var descriptor, key, _ref;
      _ref = this.descriptors;
      for (key in _ref) {
        descriptor = _ref[key];
        if (descriptor.mainActor === true) {
          return descriptor;
        }
      }
      debugger;
      throw "Rule has no decriptor for it's main actor?";
    };

    Rule.prototype.beforeSaveData = function(worldPadX, worldPadY) {
      var block, data, descriptor, extent, ref, x, y, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      extent = this.extentRelativeToRoot();
      data = {
        identifier: 'before-rule',
        width: (extent.right - extent.left) + worldPadX * 2,
        height: (extent.bottom - extent.top) + worldPadY * 2,
        wrapX: true,
        wrapY: true,
        extent: {
          top: extent.top + worldPadY,
          left: extent.left + worldPadX,
          right: extent.right + worldPadX,
          bottom: extent.bottom + worldPadY
        },
        actor_descriptors: []
      };
      _ref = this.scenario;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        block = _ref[_i];
        _ref1 = block.refs;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          ref = _ref1[_j];
          _ref2 = block.coord.split(','), x = _ref2[0], y = _ref2[1];
          descriptor = JSON.parse(JSON.stringify(this.descriptors[ref]));
          descriptor.position = {
            x: worldPadX + x / 1,
            y: worldPadY + y / 1
          };
          data.actor_descriptors.push(descriptor);
        }
      }
      return data;
    };

    Rule.prototype.findActorReference = function(actor) {
      var _this = this;
      return _.find(Object.keys(this.descriptors), function(key) {
        return _this.descriptors[key].actor_id_during_recording === actor._id;
      });
    };

    Rule.prototype.addActorReference = function(actor, options) {
      var ref, struct;
      if (options == null) {
        options = {};
      }
      struct = actor.descriptor();
      struct.actor_id_during_recording = actor._id;
      struct.appearance_ignored = true;
      this.updateActorReference(struct, actor);
      ref = Math.createUUID();
      this.descriptors[ref] = struct;
      return ref;
    };

    Rule.prototype.updateActorReference = function(struct, actor) {
      var constraint, obj, vID, value, _ref;
      struct.appearance = actor.appearance;
      struct.mainActor = actor === this.actor;
      struct.variableConstraints || (struct.variableConstraints = {});
      _ref = actor.definition.variables();
      for (vID in _ref) {
        obj = _ref[vID];
        value = actor.variableValue(vID);
        constraint = struct.variableConstraints[vID];
        if (constraint) {
          if (constraint.comparator === '=' && value !== constraint.value) {
            constraint.value = value / 1;
          }
          if (constraint.comparator === '>' && value < constraint.value) {
            constraint.value = value / 1 - 1;
          }
          if (constraint.comparator === '<' && value > constraint.value) {
            constraint.value = value / 1 + 1;
          }
        } else {
          constraint = {
            value: value,
            comparator: "=",
            ignored: true
          };
        }
        struct.variableConstraints[vID] = constraint;
      }
      delete struct._id;
      delete struct.position;
      delete struct.variableValues;
      return struct;
    };

    Rule.prototype.updateScenario = function(stage, extent) {
      var actor, block, descriptor, ref, unused, x, y, _i, _j, _k, _len, _ref, _ref1, _ref2, _ref3, _ref4, _results;
      if (extent == null) {
        extent = null;
      }
      if (!extent) {
        extent = this.extentOnStage();
      }
      unused = Object.keys(this.descriptors);
      this.scenario = [];
      for (x = _i = _ref = extent.left, _ref1 = extent.right; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; x = _ref <= _ref1 ? ++_i : --_i) {
        for (y = _j = _ref2 = extent.top, _ref3 = extent.bottom; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; y = _ref2 <= _ref3 ? ++_j : --_j) {
          block = {
            coord: "" + (x - this.extentRoot.x) + "," + (y - this.extentRoot.y),
            refs: []
          };
          this.scenario.push(block);
          _ref4 = stage.actorsAtPosition(new Point(x, y));
          for (_k = 0, _len = _ref4.length; _k < _len; _k++) {
            actor = _ref4[_k];
            ref = this.findActorReference(actor);
            if (ref) {
              this.updateActorReference(this.descriptors[ref], actor);
            } else {
              ref = this.addActorReference(actor);
            }
            block.refs.push(ref);
            delete unused[ref];
          }
        }
      }
      _results = [];
      for (ref in unused) {
        descriptor = unused[ref];
        _results.push(delete this.descriptors[ref]);
      }
      return _results;
    };

    Rule.prototype.updateActions = function(beforeStage, afterStage, options) {
      var _this = this;
      if (options == null) {
        options = {};
      }
      return this.withEachActorInExtent(beforeStage, afterStage, function(ref, beforeActor, afterActor) {
        var action, actionIndex, actionIsNew, after, before, created, definition, deleted, vID, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _results;
        definition = (beforeActor != null ? beforeActor.definition : void 0) || (afterActor != null ? afterActor.definition : void 0);
        created = !beforeActor;
        deleted = !afterActor;
        if (options.skipAppearance !== true) {
          _ref = _this.actionFor(ref, 'appearance'), action = _ref[0], actionIndex = _ref[1], actionIsNew = _ref[2];
          if (created || deleted || beforeActor.appearance === afterActor.appearance || (actionIsNew && options.existingActionsOnly)) {
            _this.actions.splice(actionIndex, 1);
          } else {
            action['to'] = afterActor.appearance;
          }
        }
        if (options.skipMove !== true) {
          _ref1 = _this.actionFor(ref, 'move'), action = _ref1[0], actionIndex = _ref1[1], actionIsNew = _ref1[2];
          if (created || deleted || afterActor.worldPos.isEqual(beforeActor.worldPos) || (actionIsNew && options.existingActionsOnly)) {
            _this.actions.splice(actionIndex, 1);
          } else {
            action.delta = "" + (afterActor.worldPos.x - beforeActor.worldPos.x) + "," + (afterActor.worldPos.y - beforeActor.worldPos.y);
          }
        }
        if (options.skipCreate !== true) {
          _ref2 = _this.actionFor(ref, 'create'), action = _ref2[0], actionIndex = _ref2[1], actionIsNew = _ref2[2];
          if (!created || (actionIsNew && options.existingActionsOnly)) {
            _this.actions.splice(actionIndex, 1);
          } else {
            _this.updateActorReference(_this.descriptors[ref], afterActor);
            action.offset = "" + (afterActor.worldPos.x - _this.extentRoot.x) + "," + (afterActor.worldPos.y - _this.extentRoot.y);
          }
        }
        if (options.skipDelete !== true) {
          _ref3 = _this.actionFor(ref, 'delete'), action = _ref3[0], actionIndex = _ref3[1], actionIsNew = _ref3[2];
          if (!deleted || (actionIsNew && options.existingActionsOnly)) {
            _this.actions.splice(actionIndex, 1);
          }
        }
        if (options.skipVariables !== true) {
          _ref4 = definition.variableIDs();
          _results = [];
          for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
            vID = _ref4[_i];
            _ref5 = _this.actionFor(ref, 'variable', function(action) {
              return action.variable === vID;
            }), action = _ref5[0], actionIndex = _ref5[1], actionIsNew = _ref5[2];
            if (created || deleted || (actionIsNew && options.existingActionsOnly)) {
              _this.actions.splice(actionIndex, 1);
              continue;
            }
            before = beforeActor.variableValue(vID);
            after = afterActor.variableValue(vID);
            action['variable'] = vID;
            if ((after - before === 1) || (action.operation === 'add')) {
              action['operation'] = 'add';
              action['value'] = after - before;
            } else if ((before - after === 1) || (action.operation === 'subtract')) {
              action['operation'] = 'subtract';
              action['value'] = before - after;
            } else {
              action['operation'] = 'set';
              action['value'] = after;
            }
            if (before === after || action['value'] / 1 === 0) {
              _results.push(_this.actions.splice(actionIndex, 1));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }
      });
    };

    Rule.prototype.updateExtent = function(beforeStage, afterStage, desiredExtent) {
      var extent,
        _this = this;
      extent = desiredExtent;
      this.withEachActorInExtent(beforeStage, afterStage, function(ref, beforeActor, afterActor) {
        var action, actor, actorHasActions, actorIsPrimary, _i, _j, _len, _len1, _ref, _ref1, _results;
        _ref = [beforeActor, afterActor];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          actor = _ref[_i];
          if (!actor) {
            continue;
          }
          actorHasActions = false;
          actorIsPrimary = actor === _this.actor;
          _ref1 = _this.actions;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            action = _ref1[_j];
            if (action.ref === ref) {
              actorHasActions = true;
            }
          }
          if (!(actorHasActions || actorIsPrimary)) {
            continue;
          }
          extent.left = Math.min(actor.worldPos.x, extent.left);
          extent.right = Math.max(actor.worldPos.x, extent.right);
          extent.top = Math.min(actor.worldPos.y, extent.top);
          _results.push(extent.bottom = Math.max(actor.worldPos.y, extent.bottom));
        }
        return _results;
      });
      this.updateScenario(beforeStage, extent);
      return extent;
    };

    Rule.prototype.extentRelativeToRoot = function() {
      var block, extent, x, y, _i, _len, _ref, _ref1;
      extent = {
        left: 10000,
        top: 10000,
        right: 0,
        bottom: 0
      };
      if (!this.scenario || this.scenario.length === 0) {
        throw "Invalid rule - no scenario! Has no extent.";
      }
      _ref = this.scenario;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        block = _ref[_i];
        _ref1 = block.coord.split(','), x = _ref1[0], y = _ref1[1];
        extent.left = Math.min(x, extent.left);
        extent.right = Math.max(x, extent.right);
        extent.top = Math.min(y, extent.top);
        extent.bottom = Math.max(y, extent.bottom);
      }
      return extent;
    };

    Rule.prototype.extentOnStage = function() {
      var extent;
      extent = this.extentRelativeToRoot();
      extent.left += this.extentRoot.x;
      extent.right += this.extentRoot.x;
      extent.top += this.extentRoot.y;
      extent.bottom += this.extentRoot.y;
      return extent;
    };

    Rule.prototype.descriptor = function() {
      return {
        _id: this._id,
        name: this.name,
        scenario: this.scenario,
        descriptors: this.descriptors,
        actions: this.actions
      };
    };

    Rule.prototype.descriptors = function() {
      return this.descriptors;
    };

    Rule.prototype.descriptorsInScenario = function() {
      var block, ref, results, _i, _j, _len, _len1, _ref, _ref1;
      results = {};
      _ref = this.scenario;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        block = _ref[_i];
        _ref1 = block.refs;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          ref = _ref1[_j];
          results[ref] = this.descriptors[ref];
        }
      }
      return results;
    };

    Rule.prototype.scenarioOffsetOf = function(searchRef) {
      var block, ref, _i, _j, _len, _len1, _ref, _ref1;
      _ref = this.scenario;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        block = _ref[_i];
        _ref1 = block.refs;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          ref = _ref1[_j];
          if (ref === searchRef) {
            return block.coord;
          }
        }
      }
    };

    Rule.prototype.actionFor = function(uuid, type, extras) {
      var action, isNew, result, resultIndex, x, _i, _ref;
      if (extras == null) {
        extras = null;
      }
      resultIndex = null;
      isNew = false;
      for (x = _i = _ref = this.actions.length - 1; _i >= 0; x = _i += -1) {
        action = this.actions[x];
        if (action.ref === uuid && action.type === type && (!extras || extras(action))) {
          result = action;
          resultIndex = x;
        }
      }
      if (!result) {
        isNew = true;
        result = {
          ref: uuid,
          type: type
        };
        resultIndex = this.actions.length;
        this.actions.push(result);
      }
      return [result, resultIndex, isNew];
    };

    Rule.prototype.withEachActorInExtent = function(beforeStage, afterStage, callback) {
      var actorsSeen, afterActor, beforeActor, extent, ref, x, y, _i, _j, _k, _l, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _results;
      extent = this.extentOnStage();
      actorsSeen = {};
      for (x = _i = _ref = extent.left, _ref1 = extent.right; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; x = _ref <= _ref1 ? ++_i : --_i) {
        for (y = _j = _ref2 = extent.top, _ref3 = extent.bottom; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; y = _ref2 <= _ref3 ? ++_j : --_j) {
          _ref4 = beforeStage.actorsAtPosition(new Point(x, y));
          for (_k = 0, _len = _ref4.length; _k < _len; _k++) {
            beforeActor = _ref4[_k];
            ref = this.findActorReference(beforeActor) || this.addActorReference(beforeActor);
            afterActor = afterStage.actorWithID(this.descriptors[ref].actor_id_during_recording);
            callback(ref, beforeActor, afterActor);
            actorsSeen[ref] = true;
          }
        }
      }
      _results = [];
      for (x = _l = _ref5 = extent.left, _ref6 = extent.right; _ref5 <= _ref6 ? _l <= _ref6 : _l >= _ref6; x = _ref5 <= _ref6 ? ++_l : --_l) {
        _results.push((function() {
          var _m, _ref7, _ref8, _results1;
          _results1 = [];
          for (y = _m = _ref7 = extent.top, _ref8 = extent.bottom; _ref7 <= _ref8 ? _m <= _ref8 : _m >= _ref8; y = _ref7 <= _ref8 ? ++_m : --_m) {
            _results1.push((function() {
              var _len1, _n, _ref9, _results2;
              _ref9 = afterStage.actorsAtPosition(new Point(x, y));
              _results2 = [];
              for (_n = 0, _len1 = _ref9.length; _n < _len1; _n++) {
                afterActor = _ref9[_n];
                ref = this.findActorReference(afterActor) || this.addActorReference(afterActor);
                if (actorsSeen[ref]) {
                  continue;
                }
                _results2.push(callback(ref, false, afterActor));
              }
              return _results2;
            }).call(this));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return Rule;

  })();

  Rule.inflateRules = function(arr) {
    var json, rules, _i, _len;
    rules = [];
    if (!(arr && arr instanceof Array)) {
      return rules;
    }
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      json = arr[_i];
      if (json['type'] === "group-flow") {
        rules.push(new FlowGroupRule(json));
      } else if (json['type'] === "group-event") {
        rules.push(new EventGroupRule(json));
      } else {
        rules.push(new Rule(json));
      }
    }
    return rules;
  };

  Rule.deflateRules = function(arr) {
    var rule, rules, _i, _len;
    rules = [];
    if (!(arr && arr instanceof Array)) {
      return rules;
    }
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      rule = arr[_i];
      rules.push(rule.descriptor());
    }
    return rules;
  };

  window.Rule = Rule;

}).call(this);
