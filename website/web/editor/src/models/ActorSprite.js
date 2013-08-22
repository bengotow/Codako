(function() {
  var ActorSprite,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ActorSprite = (function(_super) {

    __extends(ActorSprite, _super);

    function ActorSprite(definition_id, position, size) {
      this._id = Math.createUUID();
      this.definition_id = definition_id;
      this.stage = void 0;
      this.definition = void 0;
      this.currentFrame = 66;
      this.clickedInCurrentFrame = false;
      this.variableValues = {};
      this.applied = {};
      ActorSprite.__super__.constructor.call(this, position, size);
      this.setupDragging();
      this;

    }

    ActorSprite.prototype.variableValue = function(id) {
      var val, _ref;
      val = ((_ref = this.variableValues) != null ? _ref[id] : void 0) || this.definition.variables()[id]['value'];
      return val / 1;
    };

    ActorSprite.prototype.descriptor = function() {
      return {
        _id: this._id,
        definition_id: this.definition_id,
        position: {
          x: this.worldPos.x,
          y: this.worldPos.y
        },
        appearance: this.appearance,
        variableValues: this.variableValues
      };
    };

    ActorSprite.prototype.matchesDescriptor = function(descriptor) {
      var appearance_match, constraint, id, id_match, value, variable_failed, _ref;
      id_match = this.definition_id === descriptor.definition_id;
      appearance_match = this.appearance === descriptor.appearance || !descriptor.appearance;
      variable_failed = false;
      _ref = descriptor.variableConstraints;
      for (id in _ref) {
        constraint = _ref[id];
        if (constraint.ignored === true) {
          continue;
        }
        value = this.variableValue(id);
        if (constraint.comparator === '=' && value / 1 !== constraint.value / 1) {
          variable_failed = true;
        }
        if (constraint.comparator === '>' && value / 1 <= constraint.value / 1) {
          variable_failed = true;
        }
        if (constraint.comparator === '<' && value / 1 >= constraint.value / 1) {
          variable_failed = true;
        }
      }
      return id_match && !variable_failed && (appearance_match || descriptor.appearance_ignored);
    };

    ActorSprite.prototype.setAppearance = function(identifier) {
      if (identifier == null) {
        identifier = 'idle';
      }
      if (!this.definition.hasAppearance(identifier)) {
        return;
      }
      this.appearance = identifier;
      return this.gotoAndStop(this.appearance);
    };

    ActorSprite.prototype.reset = function(position) {
      ActorSprite.__super__.reset.call(this, position);
      return this.gotoAndStop(this.appearance);
    };

    ActorSprite.prototype.tick = function(elapsed) {
      if (this.dragging) {
        return;
      }
      return ActorSprite.__super__.tick.apply(this, arguments);
    };

    ActorSprite.prototype.resetRulesApplied = function() {
      return this.applied = {};
    };

    ActorSprite.prototype.tickRules = function(struct, behavior) {
      var rule, rules, _base, _i, _j, _len, _len1, _name;
      if (struct == null) {
        struct = this.definition;
      }
      if (behavior == null) {
        behavior = 'first';
      }
      rules = struct.rules;
      if (behavior === 'random') {
        rules = _.shuffle(rules);
      }
      if (behavior === 'all') {
        for (_i = 0, _len = rules.length; _i < _len; _i++) {
          rule = rules[_i];
          this.tickRule(rule);
          (_base = this.applied)[_name = struct._id] || (_base[_name] = this.applied[rule._id]);
        }
        return false;
      } else {
        for (_j = 0, _len1 = rules.length; _j < _len1; _j++) {
          rule = rules[_j];
          this.tickRule(rule);
          if (this.applied[rule._id]) {
            return this.applied[struct._id] = true;
          }
        }
      }
      return this.applied[struct._id];
    };

    ActorSprite.prototype.tickRule = function(rule) {
      if (rule.type === 'group-event') {
        if (this.checkEvent(rule)) {
          this.applied[rule._id] = true;
          this.tickRules(rule, 'first');
        }
      } else if (rule.type === 'group-flow') {
        this.applied[rule._id] = this.tickRules(rule, rule.behavior);
      } else if (this.checkRuleScenario(rule)) {
        this.applied[rule._id] = true;
        this.applyRule(rule);
      } else {
        this.applied[rule._id] = false;
      }
      return this.applied[rule._id];
    };

    ActorSprite.prototype.checkRuleScenario = function(rule) {
      var block, descriptors, pos, _i, _len, _ref;
      _ref = rule.scenario;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        block = _ref[_i];
        pos = Point.sum(this.worldPos, Point.fromString(block.coord));
        descriptors = _.map(block.refs, function(ref) {
          return rule.descriptors[ref];
        });
        if (!this.stage.actorsAtPositionMatchDescriptors(pos, descriptors)) {
          return false;
        }
      }
      return true;
    };

    ActorSprite.prototype.checkEvent = function(trigger) {
      if (trigger.event === 'key') {
        if (window.Game.isKeyDown(trigger.code)) {
          return true;
        }
      }
      if (trigger.event === 'click') {
        return this.clickedInCurrentFrame;
      }
      if (trigger.event === 'idle') {
        return true;
      }
      return false;
    };

    ActorSprite.prototype.applyRule = function(rule) {
      var action, actor, actorsForRefs, descriptor, offset, pos, rootPos, _i, _len, _ref, _results;
      rootPos = new Point(this.worldPos.x, this.worldPos.y);
      actorsForRefs = {};
      _ref = rule.actions;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        action = _ref[_i];
        descriptor = rule.descriptors[action.ref];
        offset = action.offset || rule.scenarioOffsetOf(action.ref);
        pos = Point.sum(rootPos, Point.fromString(offset));
        if (this.stage) {
          pos = this.stage.wrappedPosition(pos);
        }
        actor = actorsForRefs[action.ref];
        if (!actor) {
          actor = this.stage.actorMatchingDescriptor(descriptor, this.stage.actorsAtPosition(pos));
          actorsForRefs[action.ref] = actor;
        }
        if (action.type === 'create') {
          actor = this.stage.addActor(descriptor, pos);
          if (!rule.editing) {
            _results.push(actor._id = Math.createUUID());
          } else {
            _results.push(void 0);
          }
        } else if (actor) {
          _results.push(actor.applyRuleAction(action, rule));
        } else {
          debugger;
          throw "Couldn't find the actor for performing rule: " + rule;
        }
      }
      return _results;
    };

    ActorSprite.prototype.applyRuleAction = function(action, rule) {
      var current, p;
      if (rule == null) {
        rule = void 0;
      }
      if (!action) {
        return;
      }
      if (action.type === 'move') {
        p = Point.sum(this.worldPos, Point.fromString(action.delta));
        if (this.stage) {
          p = this.stage.wrappedPosition(p);
        }
        return this.setWorldPos(p);
      } else if (action.type === 'delete') {
        if (this.stage) {
          this.stage.removeActor(this);
        }
        return this.setWorldPos(-100, -100);
      } else if (action.type === 'appearance') {
        return this.setAppearance(action.to);
      } else if (action.type === 'variable') {
        current = this.variableValue(action.variable);
        return this.variableValues[action.variable] = Math.applyOperation(current, action.operation, action.value);
      } else {
        return console.log('Not sure how to apply action', action);
      }
    };

    ActorSprite.prototype.setupDragging = function() {
      var _this = this;
      this.dragging = false;
      return this.addEventListener('mousedown', function(e) {
        var grabX, grabY;
        if (!_this.stage.draggingEnabled) {
          return;
        }
        grabX = e.stageX - _this.x;
        grabY = e.stageY - _this.y;
        _this.alpha = 0.5;
        _this.dragging = true;
        e.addEventListener('mousemove', function(e) {
          _this.x = e.stageX - grabX;
          return _this.y = e.stageY - grabY;
        });
        return e.addEventListener('mouseup', function(e) {
          var p;
          p = new Point(Math.round(_this.x / Tile.WIDTH), Math.round(_this.y / Tile.HEIGHT));
          return _this.dropped(p);
        });
      });
    };

    ActorSprite.prototype.dropped = function(point) {
      this.dragging = false;
      this.alpha = 1;
      return window.Game.onActorDragged(this, this.stage, point);
    };

    return ActorSprite;

  })(Sprite);

  window.ActorSprite = ActorSprite;

}).call(this);
