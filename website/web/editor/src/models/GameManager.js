(function() {
  var GameManager,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  GameManager = (function() {

    function GameManager(stagePane1, stagePane2, renderingStage) {
      this.recordingHandleDragged = __bind(this.recordingHandleDragged, this);

      this.recordingActionModified = __bind(this.recordingActionModified, this);

      this.onActorClicked = __bind(this.onActorClicked, this);

      this.loadStatusChanged = __bind(this.loadStatusChanged, this);

      var _this = this;
      this.world_id = null;
      this.stage_id = null;
      this.library = new LibraryManager('default', this.loadStatusChanged);
      this.content = new ContentManager(this.loadStatusChanged);
      this.selectedActor = null;
      this.selectedRule = null;
      this.tool = 'pointer';
      this.simulationFrameRate = 500;
      this.simulationFrameNextTime = 0;
      this.prevFrames = [];
      this.elapsed = 0;
      this.running = false;
      this.keysDown = {};
      $('body').keydown(function(e) {
        if ($(e.target).prop('tagName') === 'INPUT') {
          return;
        }
        if ($(e.target).prop('id') === 'pixelArtModal') {
          return;
        }
        if ($(e.target).prop('id') === 'keyInputModal') {
          return;
        }
        if (e.keyCode === 127 || e.keyCode === 8) {
          e.preventDefault();
          if (_this.selectedActor) {
            _this.selectedActor.stage.removeActor(_this.selectedActor);
          }
          _this.selectActor(null);
          _this.save();
        }
        return _this.keysDown[e.keyCode] = true;
      });
      document.onkeyup = function(e) {
        if (!_this.running) {
          return _this.keysDown[e.keyCode] = false;
        }
      };
      this.mainStage = this.stagePane1 = stagePane1;
      this.stagePane2 = stagePane2;
      this.stageTotalWidth = this.stagePane1.canvas.width;
      this.renderingStage = renderingStage;
      this;

    }

    GameManager.prototype.load = function(world_id, stage_id, callback) {
      var _this = this;
      if (callback == null) {
        callback = null;
      }
      this.dispose();
      this.world_id = world_id;
      this.stage_id = stage_id;
      this.loadStatusChanged({
        progress: 0
      });
      return $.ajax({
        url: "/api/v0/worlds/" + world_id + "/stages/" + stage_id
      }).done(function(stage) {
        return _this.content.fetchLevelAssets(stage.resources, function() {
          _this.loadLevelDataReady(stage);
          if (callback) {
            return callback(null);
          }
        });
      });
    };

    GameManager.prototype.loadStatusChanged = function(state) {
      if (state.progress < 100) {
        return this.mainStage.setStatusMessage("Downloading " + state.progress + "%");
      } else {
        return this.mainStage.setStatusMessage(null);
      }
    };

    GameManager.prototype.loadLevelDataReady = function(data) {
      var _this = this;
      return this.mainStage.prepareWithData(data, function(err) {
        _this.loadStatusChanged({
          progress: 100
        });
        _this.initialGameTime = Ticker.getTime();
        _this.update();
        Ticker.addListener(_this);
        Ticker.useRAF = false;
        Ticker.setFPS(30);
        return window.rootScope.$apply();
      });
    };

    GameManager.prototype.tick = function() {
      return this.update();
    };

    GameManager.prototype.update = function(forceRules) {
      var elapsed, time;
      if (forceRules == null) {
        forceRules = false;
      }
      time = Ticker.getTime();
      elapsed = (time - this.initialGameTime) / 1000;
      if ((this.running && time > this.simulationFrameNextTime) || forceRules) {
        this.frameSave();
        this.frameAdvance();
        window.rulesScope.$apply();
        window.variablesScope.$apply();
        return this.mainStage.update(elapsed);
      } else {
        if (this.stagePane1.onscreen()) {
          this.stagePane1.update(elapsed);
        }
        if (this.stagePane2.onscreen()) {
          return this.stagePane2.update(elapsed);
        }
      }
    };

    GameManager.prototype.frameRewind = function() {
      if (!this.prevFrames.length) {
        return alert("Sorry, you can't rewind any further!");
      }
      this.selectedActor = null;
      return this.mainStage.prepareWithData(this.prevFrames.pop(), function() {
        window.rulesScope.$apply();
        return window.variablesScope.$apply();
      });
    };

    GameManager.prototype.frameSave = function() {
      var _ref;
      if ((_ref = this.selectedRule) != null ? _ref.editing : void 0) {
        throw "This shouldn't happen!";
      }
      if (this.prevFrames.length > 20) {
        this.prevFrames = this.prevFrames.slice(1);
      }
      return this.prevFrames.push(this.mainStage.saveData());
    };

    GameManager.prototype.frameAdvance = function() {
      var actor, actorsPresentBeforeFrame, x, _i, _ref;
      actorsPresentBeforeFrame = [].concat(this.mainStage.actors);
      for (x = _i = _ref = actorsPresentBeforeFrame.length - 1; _i >= 0; x = _i += -1) {
        actor = actorsPresentBeforeFrame[x];
        actor.resetRulesApplied();
        actor.tickRules();
        actor.clickedInCurrentFrame = false;
      }
      this.keysDown = {};
      return this.simulationFrameNextTime = Ticker.getTime() + this.simulationFrameRate;
    };

    GameManager.prototype.dispose = function() {
      this.selectedActor = null;
      this.stagePane1.dispose();
      return this.stagePane2.dispose();
    };

    try {
      GameManager.content.pauseSound('globalMusic');
    } catch (_error) {}

    GameManager.prototype.save = function(options) {
      var isAsync;
      if (options == null) {
        options = {};
      }
      if (this.selectedRule && this.selectedRule.editing) {
        console.log('Trying to save while editing a rule??');
        return;
      }
      isAsync = true;
      if (options.async !== void 0) {
        isAsync = options.async;
      }
      return $.ajax({
        url: "/api/v0/worlds/" + this.world_id + "/stages/" + this.stage_id,
        data: angular.toJson(this.mainStage.saveData(options)),
        contentType: 'application/json',
        type: 'POST',
        async: isAsync
      }).done(function() {
        return console.log('Stage Saved');
      });
    };

    GameManager.prototype.isKeyDown = function(code) {
      return this.keysDown[code];
    };

    GameManager.prototype.selectActor = function(actor) {
      if (this.selectedActor === actor) {
        return;
      }
      if (this.selectedActor) {
        this.selectedActor.setSelected(false);
      }
      this.selectedDefinition = null;
      if (!window.rootScope.$$phase) {
        window.rootScope.$apply();
      }
      this.selectedActor = actor;
      if (this.selectedActor) {
        this.selectedDefinition = this.selectedActor.definition;
      }
      if (this.selectedActor) {
        return this.selectedActor.setSelected(true);
      }
    };

    GameManager.prototype.selectDefinition = function(definition) {
      if (this.selectedActor) {
        this.selectedActor.setSelected(false);
      }
      return this.selectedDefinition = definition;
    };

    GameManager.prototype.setTool = function(t) {
      $('body').removeClass("tool-" + this.tool);
      this.tool = t;
      $('body').addClass("tool-" + this.tool);
      return window.rootScope.$broadcast('set_tool', 'pointer');
    };

    GameManager.prototype.resetToolAfterAction = function() {
      var canRepeat;
      canRepeat = this.tool === 'delete';
      if (!(canRepeat && (this.keysDown[16] || this.keysDown[17] || this.keysDown[18]))) {
        return this.setTool('pointer');
      }
    };

    GameManager.prototype.onActorClicked = function(actor) {
      if (actor) {
        if (this.running) {
          actor.clickedInCurrentFrame = true;
        }
        if (this.tool === 'paint') {
          window.rootScope.$broadcast('edit_appearance', {
            actor_definition: actor.definition,
            identifier: actor.appearance
          });
        }
        if (this.tool === 'delete') {
          this.onActorDeleted(actor, actor.stage);
        }
        if (this.tool === 'record') {
          this.editNewRuleForActor(actor);
        }
      }
      return this.resetToolAfterAction();
    };

    GameManager.prototype.onActorDoubleClicked = function(actor) {
      this.selectActor(actor);
      return window.rootScope.$digest();
    };

    GameManager.prototype.onActorVariableValueEdited = function(actor, varName, val) {
      return this.wrapApplyChangeTo(actor, actor.stage, function() {
        return actor.variableValues[varName] = val;
      });
    };

    GameManager.prototype.onActorDragged = function(actor, stage, point) {
      if (this.selectedRule) {
        if (!point.isInside(this.mainStage.recordingExtent)) {
          return;
        }
      }
      return this.wrapApplyChangeTo(actor, stage, function() {
        return actor.setWorldPos(point);
      });
    };

    GameManager.prototype.onActorDeleted = function(actor, stage) {
      return this.wrapApplyChangeTo(actor, stage, function() {
        return stage.removeActor(actor);
      });
    };

    GameManager.prototype.onAppearancePlaced = function(actor, stage, appearance) {
      var _this = this;
      return this.wrapApplyChangeTo(actor, stage, function() {
        actor.setAppearance(appearance);
        return _this.update();
      });
    };

    GameManager.prototype.onActorPlaced = function(actor, stage) {
      var _this = this;
      return this.wrapApplyChangeTo(actor, stage, function() {
        return _this.update();
      });
    };

    GameManager.prototype.wrapApplyChangeTo = function(actor, stage, applyCallback) {
      var extent,
        _this = this;
      applyCallback();
      if (this.selectedRule) {
        if (stage === this.stagePane1) {
          extent = this.selectedRule.extentOnStage();
          if (actor._id === this.selectedRule.actor._id) {
            this.selectedRule.setMainActor(actor);
          }
          this.selectedRule.updateScenario(this.stagePane1, extent);
          this.selectedRule.updateActions(this.stagePane1, this.stagePane2, {
            existingActionsOnly: true,
            skipVariables: true,
            skipAppearance: true
          });
          this.mirrorStage1OntoStage2({}, function() {
            return _this.selectedRule.updateActions(_this.stagePane1, _this.stagePane2, {
              existingActionsOnly: true,
              skipMove: true
            });
          });
        }
        if (stage === this.stagePane2 && this.stagePane2.onscreen()) {
          return this.selectedRule.updateActions(this.stagePane1, this.stagePane2);
        }
      } else {
        if (stage === this.mainStage) {
          return this.save();
        }
      }
    };

    GameManager.prototype.setStageBackground = function(background_key) {
      this.stagePane1.setBackground(background_key, true);
      this.stagePane2.setBackground(background_key, true);
      return this.save();
    };

    GameManager.prototype.editNewRuleForActor = function(actor) {
      var initialExtent;
      if (!actor) {
        return;
      }
      window.rootScope.$broadcast('start_compose_rule');
      initialExtent = {
        left: actor.worldPos.x,
        right: actor.worldPos.x,
        top: actor.worldPos.y,
        bottom: actor.worldPos.y
      };
      this.selectedRule = new Rule();
      this.selectedRule.setMainActor(actor);
      this.selectedRule.updateScenario(this.mainStage, initialExtent);
      this.mainStage.setRecordingExtent(initialExtent, 'masked');
      this.mainStage.setRecordingCentered(false);
      return this.selectActor(actor);
    };

    GameManager.prototype.editRule = function(rule, actor, isNewRule) {
      if (actor == null) {
        actor = null;
      }
      if (isNewRule == null) {
        isNewRule = false;
      }
      if (!rule) {
        return;
      }
      if (this.selectedRule && this.selectedRule !== rule) {
        this.saveRecording();
      }
      if (actor && this.selectedActor !== actor) {
        this.selectActor(actor);
      }
      this.selectedRule = rule;
      return this.enterRecordingMode(isNewRule);
    };

    GameManager.prototype.enterRecordingMode = function(demonstrateOnCurrentStage) {
      var extent, stageData, _beforeStageReady,
        _this = this;
      if (demonstrateOnCurrentStage == null) {
        demonstrateOnCurrentStage = false;
      }
      window.rootScope.$broadcast('start_edit_rule');
      this.previousRuleState = JSON.parse(JSON.stringify(this.selectedRule.descriptor()));
      if (!this.previousGameState) {
        this.previousGameState = this.mainStage.saveData();
      }
      this.selectedRule.editing = true;
      extent = null;
      _beforeStageReady = function() {
        var actor, extentRelative, extentRootPos;
        _this.stagePane1.setRecordingExtent(extent, 'white');
        _this.stagePane1.setRecordingCentered(true);
        _this.stagePane1.setDisplayWidth(_this.stageTotalWidth / 2 - 2);
        extentRelative = _this.selectedRule.extentRelativeToRoot();
        extentRootPos = new Point(-extentRelative.left + extent.left, -extentRelative.top + extent.top);
        actor = _this.stagePane1.actorMatchingDescriptor(_this.selectedRule.mainActorDescriptor(), _this.stagePane1.actorsAtPosition(extentRootPos));
        _this.selectedRule.setMainActor(actor);
        if (_this.selectedActor !== actor) {
          _this.selectActor(actor);
        }
        return _this.mirrorStage1OntoStage2({
          shouldSelect: true
        });
      };
      if (demonstrateOnCurrentStage) {
        extent = this.selectedRule.extentOnStage();
        this.stagePane1.draggingEnabled = false;
        return _beforeStageReady();
      } else {
        stageData = this.selectedRule.beforeSaveData(6, 6);
        extent = stageData.extent;
        this.stagePane1.draggingEnabled = true;
        return this.stagePane1.prepareWithData(stageData, _beforeStageReady);
      }
    };

    GameManager.prototype.mirrorStage1OntoStage2 = function(options, callback) {
      var _ref,
        _this = this;
      if (options == null) {
        options = {};
      }
      options.shouldSelect || (options.shouldSelect = ((_ref = this.selectedActor) != null ? _ref.stage : void 0) === this.stagePane2);
      return this.stagePane2.prepareWithData(this.mainStage.saveData(), function() {
        var actorToSelect, ruleActor;
        _this.stagePane2.setRecordingExtent(_this.mainStage.recordingExtent, 'white');
        _this.stagePane2.setRecordingCentered(true);
        _this.stagePane2.setDisplayWidth(_this.stageTotalWidth / 2 - 2);
        ruleActor = _this.stagePane2.actorWithID(_this.selectedRule.actor._id);
        ruleActor.applyRule(_this.selectedRule);
        actorToSelect = _this.selectedActor || _this.selectedRule.actor;
        if (actorToSelect && options.shouldSelect) {
          _this.selectActor(_this.stagePane2.actorWithID(actorToSelect._id));
        }
        if (callback) {
          return callback();
        }
      });
    };

    GameManager.prototype.exitRecordingMode = function() {
      var _this = this;
      window.rootScope.$broadcast('end_edit_rule');
      this.stagePane1.clearRecording();
      this.stagePane1.setDisplayWidth(this.stageTotalWidth);
      this.stagePane2.clearRecording();
      this.stagePane2.setDisplayWidth(0);
      if (this.previousGameState) {
        this.stagePane1.prepareWithData(this.previousGameState, function() {
          var previouslySelectedActor;
          if (_this.selectedRule.actor) {
            previouslySelectedActor = _this.stagePane1.actorWithID(_this.selectedRule.actor._id);
            if (previouslySelectedActor) {
              _this.selectActor(previouslySelectedActor);
            }
          }
          _this.previousGameState = void 0;
          return _this.previousRuleState = void 0;
        });
      }
      return this.selectedRule = null;
    };

    GameManager.prototype.recordingActionModified = function() {
      return this.mirrorStage1OntoStage2();
    };

    GameManager.prototype.recordingHandleDragged = function(handle, finished) {
      var extent;
      if (finished == null) {
        finished = false;
      }
      extent = this.mainStage.recordingExtent;
      if (handle.side === 'left') {
        extent.left = Math.min(handle.worldPos.x + 1, extent.right);
      }
      if (handle.side === 'right') {
        extent.right = Math.max(extent.left, handle.worldPos.x - 1);
      }
      if (handle.side === 'top') {
        extent.top = Math.min(handle.worldPos.y + 1, extent.bottom);
      }
      if (handle.side === 'bottom') {
        extent.bottom = Math.max(extent.top, handle.worldPos.y - 1);
      }
      extent = this.selectedRule.updateExtent(this.stagePane1, this.stagePane2, extent);
      this.stagePane1.setRecordingExtent(extent);
      this.stagePane2.setRecordingExtent(extent);
      if (!window.rootScope.$$phase) {
        return window.rootScope.$apply();
      }
    };

    GameManager.prototype.revertRecording = function() {
      var key, value, _ref, _results;
      _ref = this.previousRuleState;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(this.selectedRule[key] = value);
      }
      return _results;
    };

    GameManager.prototype.saveRecording = function() {
      var actor;
      actor = this.selectedRule.actor;
      actor.definition.addRule(this.selectedRule);
      actor.definition.clearCacheForRule(this.selectedRule);
      return actor.definition.save();
    };

    GameManager.prototype.renderRule = function(rule, applyActions) {
      var action, actor, block, coord, created_actors, data, point, ref, xmax, xmin, ymax, ymin, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3,
        _this = this;
      if (applyActions == null) {
        applyActions = false;
      }
      this.renderingStage.addChild(new Bitmap(this.content.imageNamed('Layer0_0')));
      xmin = xmax = ymin = ymax = 0;
      created_actors = {};
      _ref = rule.scenario;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        block = _ref[_i];
        coord = Point.fromString(block.coord);
        xmin = Math.min(xmin, coord.x);
        xmax = Math.max(xmax, coord.x);
        ymin = Math.min(ymin, coord.y);
        ymax = Math.max(ymax, coord.y);
      }
      this.renderingStage.canvas.width = (xmax - xmin + 1) * Tile.WIDTH;
      this.renderingStage.canvas.height = (ymax - ymin + 1) * Tile.HEIGHT;
      this.renderingStage.addActor = function(ref, offset) {
        var actor, descriptor;
        descriptor = rule.descriptors[ref];
        actor = window.Game.library.instantiateActorFromDescriptor(descriptor, new Point(-xmin + offset.x, -ymin + offset.y));
        actor.tick();
        _this.renderingStage.addChild(actor);
        return created_actors[ref] = actor;
      };
      _ref1 = rule.scenario;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        block = _ref1[_j];
        point = Point.fromString(block.coord);
        _ref2 = block.refs;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          ref = _ref2[_k];
          this.renderingStage.addActor(ref, point);
        }
      }
      if (applyActions && rule.actions) {
        _ref3 = rule.actions;
        for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
          action = _ref3[_l];
          if (action.type === 'create') {
            this.renderingStage.addActor(action.ref, Point.fromString(action.offset));
          } else {
            actor = created_actors[action.ref];
            actor.applyRuleAction(action);
            actor.tick();
          }
        }
      }
      this.renderingStage.update();
      data = this.renderingStage.canvas.toDataURL();
      this.renderingStage.removeAllChildren();
      return data;
    };

    return GameManager;

  })();

  window.GameManager = GameManager;

  window.Tile = {
    WIDTH: 40,
    HEIGHT: 40
  };

}).call(this);
