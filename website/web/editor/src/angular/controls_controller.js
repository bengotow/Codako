(function() {
  var ControlsCtrl;

  ControlsCtrl = function($scope) {
    window.controlsScope = $scope;
    $scope.control_set = 'testing';
    $scope.$root.$on('start_compose_rule', function(msg, args) {
      return $scope.control_set = 'record-preflight';
    });
    $scope.$root.$on('start_edit_rule', function(msg, args) {
      return $scope.control_set = 'recording';
    });
    $scope.$root.$on('end_edit_rule', function(msg, args) {
      return $scope.control_set = 'testing';
    });
    $scope.$root.$on('set_tool', function(msg, args) {
      if (!$scope.$$phase) {
        return $scope.$apply();
      }
    });
    $scope.set_running = function(r) {
      return window.Game.running = r;
    };
    $scope.step = function() {
      return window.Game.update(true);
    };
    $scope.step_back = function() {
      return window.Game.frameRewind();
    };
    $scope.reset = function() {};
    $scope.speed = function() {
      if (!window.Game) {
        return 0;
      }
      return window.Game.simulationFrameRate;
    };
    $scope.set_speed = function(speed) {
      return window.Game.simulationFrameRate = speed;
    };
    $scope.running = function() {
      if (!window.Game) {
        return false;
      }
      return window.Game.running;
    };
    $scope.class_for_btn = function(istrue) {
      if (istrue) {
        return 'btn btn-info';
      } else {
        return 'btn';
      }
    };
    $scope.tool = function() {
      var _ref;
      return (_ref = window.Game) != null ? _ref.tool : void 0;
    };
    $scope.set_tool = function(t) {
      if (t === 'record' && $scope.control_set !== 'testing') {
        return alert("You're already recording a rule! Exit the recording mode by clicking 'Cancel' or 'Save Recording' and then try again.");
      }
      return window.Game.setTool(t);
    };
    $scope.definition_name = function() {
      if (!(window.Game && window.Game.selectedDefinition)) {
        return void 0;
      }
      return window.Game.selectedDefinition.name;
    };
    $scope.start_recording = function() {
      return window.Game.editRule(window.Game.selectedRule, window.Game.selectedRule.actor, true);
    };
    $scope.cancel_recording = function() {
      window.Game.revertRecording();
      return window.Game.exitRecordingMode();
    };
    $scope.save_recording = function() {
      window.Game.saveRecording();
      return window.Game.exitRecordingMode();
    };
    $scope.recording_descriptors = function() {
      var _ref, _ref1;
      return (_ref = window.Game) != null ? (_ref1 = _ref.selectedRule) != null ? _ref1.descriptorsInScenario() : void 0 : void 0;
    };
    $scope.recording_actions = function() {
      var _ref, _ref1;
      return (_ref = window.Game) != null ? (_ref1 = _ref.selectedRule) != null ? _ref1.actions : void 0 : void 0;
    };
    $scope.recording_action_modified = function() {
      var _ref;
      return (_ref = window.Game) != null ? _ref.recordingActionModified() : void 0;
    };
    $scope.toggle_appearance_constraint = function(ref) {
      var descriptor, _ref, _ref1;
      descriptor = (_ref = window.Game) != null ? (_ref1 = _ref.selectedRule) != null ? _ref1.descriptors[ref] : void 0 : void 0;
      return descriptor.appearance_ignored = !descriptor.appearance_ignored;
    };
    $scope.toggle_variable_constraint = function(ref, variable_id) {
      var constraint, descriptor, _ref, _ref1;
      descriptor = (_ref = window.Game) != null ? (_ref1 = _ref.selectedRule) != null ? _ref1.descriptors[ref] : void 0 : void 0;
      constraint = descriptor.variableConstraints[variable_id];
      return constraint.ignored = !constraint.ignored;
    };
    $scope.html_for_actor = function(ref, possessive) {
      var name;
      name = $scope.name_for_referenced_actor(ref);
      if (possessive) {
        name += "'s";
      }
      return "<code><img src=\"" + $scope.icon_for_referenced_actor(ref) + "\">" + name + "</code>";
    };
    $scope.html_for_appearance = function(ref, appearance) {
      return "<code><img src=\"" + $scope.icon_for_referenced_actor(ref, appearance) + "\">" + $scope.name_for_appearance(appearance) + "</code>";
    };
    $scope.icon_for_referenced_actor = function(ref, appearance_id) {
      var definition, descriptor, _ref, _ref1;
      if (appearance_id == null) {
        appearance_id = null;
      }
      descriptor = (_ref = window.Game) != null ? (_ref1 = _ref.selectedRule) != null ? _ref1.descriptors[ref] : void 0 : void 0;
      appearance_id || (appearance_id = descriptor.appearance);
      definition = window.Game.library.definitions[descriptor.definition_id];
      return definition.iconForAppearance(appearance_id, 26, 26) || "";
    };
    $scope.icon_for_move = function(delta) {
      var h, size, w, x, y, _ref;
      size = 10;
      _ref = delta.split(','), x = _ref[0], y = _ref[1];
      w = Math.abs(x) + 1;
      h = Math.abs(y) + 1;
      return window.withTempCanvas(w * size, h * size, function(canvas, context) {
        var after, before, translate, xx, yy, _i, _j;
        context.fillStyle = 'rgba(255,255,255,1)';
        context.fillRect(0, 0, w * size, h * size);
        context.beginPath();
        context.strokeStyle = 'rgba(0,0,0,0.3)';
        for (xx = _i = 0; 0 <= w ? _i <= w : _i >= w; xx = 0 <= w ? ++_i : --_i) {
          context.moveTo(xx * size, 0);
          context.lineTo(xx * size, h * size);
        }
        for (yy = _j = 0; 0 <= h ? _j <= h : _j >= h; yy = 0 <= h ? ++_j : --_j) {
          context.moveTo(0, yy * size);
          context.lineTo(w * size, yy * size);
        }
        context.stroke();
        before = {
          x: 0,
          y: 0
        };
        after = {
          x: x / 1,
          y: y / 1
        };
        translate = {
          x: 0,
          y: 0
        };
        if (after.x < 0) {
          translate.x = -after.x;
        }
        if (after.y < 0) {
          translate.y = -after.y;
        }
        context.fillStyle = 'rgba(150,150,150,1)';
        context.fillRect((before.x + translate.x) * size, (before.y + translate.y) * size, size, size);
        context.fillStyle = 'rgba(255,0,0,1)';
        context.fillRect((after.x + translate.x) * size, (after.y + translate.y) * size, size, size);
        return canvas.toDataURL();
      });
    };
    $scope.name_for_referenced_actor = function(ref) {
      var definition, descriptor, _ref, _ref1;
      if (!ref) {
        return "Unknown";
      }
      descriptor = (_ref = window.Game) != null ? (_ref1 = _ref.selectedRule) != null ? _ref1.descriptors[ref] : void 0 : void 0;
      if (!descriptor) {
        return "Unknown";
      }
      definition = window.Game.library.definitions[descriptor.definition_id];
      return definition.name;
    };
    $scope.name_for_appearance = function(id) {
      var definition, key, _ref;
      _ref = window.Game.library.definitions;
      for (key in _ref) {
        definition = _ref[key];
        if (definition.hasAppearance(id)) {
          return definition.nameForAppearance(id);
        }
      }
      return "Unknown";
    };
    $scope.name_for_variable = function(id) {
      var definition, entry, key, _ref;
      _ref = window.Game.library.definitions;
      for (key in _ref) {
        definition = _ref[key];
        entry = definition.variables()[id];
        if (!entry) {
          continue;
        }
        return entry.name;
      }
    };
    $scope.class_for_appearance_constraint = function(descriptor) {
      if (descriptor.appearance_ignored) {
        return 'condition ignored';
      }
      return 'condition';
    };
    $scope.class_for_variable_constraint = function(constraint) {
      if (constraint.ignored) {
        return 'condition ignored';
      }
      return 'condition';
    };
    $scope.save_recording_check_value = function(id) {};
    $scope.ondrop = function(event, ui) {
      var checkID, variable, variableID, variableValue;
      variableID = ui.draggable.data('identifier');
      if (variableID.slice(0, 9) !== 'variable:') {
        return;
      }
      variableID = variableID.slice(9);
      variable = window.Game.selectedDefinition.variables()[variableID];
      variableValue = window.Game.selectedActor.variableValue(variableID);
      checkID = $(event.target).data('identifier');
      window.Game.recordingCheck(checkID)['_id'] = variableID;
      if (window.Game.recordingChecks[-1]._id === checkID) {
        return window.Game.addRecordingCheck();
      }
    };
    return $scope._withTempCanvas = function(w, h, func) {
      var canvas, ret;
      canvas = document.createElement("canvas");
      canvas.width = w;
      canvas.height = h;
      document.body.appendChild(canvas);
      ret = func(canvas);
      document.body.removeChild(canvas);
      return ret;
    };
  };

  window.ControlsCtrl = ControlsCtrl;

}).call(this);
