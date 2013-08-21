(function() {
  var VariablesCtrl;

  VariablesCtrl = function($scope) {
    window.variablesScope = $scope;
    $scope.var_width = 90;
    $scope.var_height = 80;
    $scope.variables = function() {
      var _ref, _ref1;
      return (_ref = window.Game) != null ? (_ref1 = _ref.selectedDefinition) != null ? _ref1.variables() : void 0 : void 0;
    };
    $scope.variables_empty = function() {
      return $scope.variables() && $.isEmptyObject($scope.variables());
    };
    $scope.add_variable = function() {
      var definition, id, newVar, taken, variable, x, y, _ref, _ref1;
      definition = (_ref = window.Game) != null ? _ref.selectedDefinition : void 0;
      newVar = definition.addVariable();
      x = 0;
      y = 0;
      while (y < 10) {
        taken = false;
        _ref1 = definition.variables();
        for (id in _ref1) {
          variable = _ref1[id];
          if (variable.x === x && variable.y === y) {
            taken = true;
            break;
          }
        }
        if (taken === false) {
          break;
        } else {
          x += 1;
          if (x > 2) {
            x = 0;
            y += 1;
          }
        }
      }
      newVar.x = x;
      newVar.y = y;
      return definition.save();
    };
    $scope.variable_clicked = function(variable) {
      var definition, _ref;
      if (window.Game.tool === 'delete') {
        definition = (_ref = window.Game) != null ? _ref.selectedDefinition : void 0;
        if (confirm("Are you sure you want to delete the variable '" + variable.name + "'? When you delete the variable, it will be deleted from all '" + definition.name + "'.")) {
          definition.removeVariable(variable);
          definition.save();
        }
      }
      return window.Game.resetToolAfterAction();
    };
    $scope.edit_variable_attr = function(event, attr) {
      var id, variableEl;
      variableEl = $(event.target).parent();
      id = variableEl.data('identifier');
      variableEl.find("div").css('display', 'none');
      variableEl.find("input").css('display', 'inherit');
      return variableEl.find("input." + attr).focus();
    };
    $scope.save_variable_attr = function(event, attr) {
      var definition, id, value, variableEl;
      variableEl = $(event.target).parent();
      id = variableEl.data('identifier').slice('variable:'.length);
      value = $(event.target).val();
      if ((value != null ? value.length : void 0) === 0 && (attr = 'name')) {
        value = 'Untitled';
      }
      if (attr === 'value' && window.Game.selectedActor) {
        window.Game.onActorVariableValueEdited(window.Game.selectedActor, id, value);
      } else {
        definition = window.Game.selectedDefinition;
        definition.variables()[id][attr] = value;
        definition.save();
      }
      variableEl.find("div").css('display', 'inherit');
      variableEl.find("input").css('display', 'none');
      return variableEl.find("div." + attr).text(value);
    };
    $scope.value_for_variable = function(id) {
      var _ref;
      if (!((_ref = window.Game) != null ? _ref.selectedActor : void 0)) {
        return window.Game.selectedDefinition.variables()[id]['value'];
      }
      return window.Game.selectedActor.variableValue(id);
    };
    $scope.css_for_variable = function(variable) {
      return "left:" + (variable.x * $scope.var_width) + "px; top:" + (variable.y * $scope.var_height) + "px;";
    };
    return $scope.ondrop = function(event, ui) {
      var id, left, maxLeft, maxTop, top, variable;
      maxLeft = ($(event.target).innerWidth() - ui.draggable.outerWidth()) / $scope.var_width;
      maxTop = ($(event.target).innerHeight() - ui.draggable.outerHeight()) / $scope.var_height;
      left = Math.round(ui.draggable.css('left').replace('px', '') / $scope.var_width);
      left = Math.max(0, Math.min(maxLeft, left));
      top = Math.round(ui.draggable.css('top').replace('px', '') / $scope.var_height);
      top = Math.max(0, Math.min(maxTop, top));
      ui.draggable.css('left', "" + (left * $scope.var_width) + "px");
      ui.draggable.css('top', "" + (top * $scope.var_height) + "px");
      id = ui.draggable.data('identifier').slice('variable:'.length);
      variable = window.Game.selectedDefinition.variables()[id];
      variable.x = left;
      variable.y = top;
      return window.Game.selectedDefinition.save();
    };
  };

  window.VariablesCtrl = VariablesCtrl;

}).call(this);
