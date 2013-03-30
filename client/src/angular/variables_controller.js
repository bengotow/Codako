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
    $scope.add_variable = function() {
      var _ref, _ref1;
      if ((_ref = window.Game) != null) {
        _ref.selectedDefinition.addVariable();
      }
      return (_ref1 = window.Game) != null ? _ref1.selectedDefinition.save() : void 0;
    };
    $scope.select_variable = function(id) {
      var _ref;
      if (window.Game.tool === 'delete') {
        if (confirm('Are you sure you want to delete this variable?')) {
          if ((_ref = window.Game) != null) {
            _ref.selectedDefinition.removeVariable(id);
          }
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
      id = variableEl.data('identifier');
      value = $(event.target).val();
      if ((value != null ? value.length : void 0) === 0 && (attr = 'name')) {
        value = 'Untitled';
      }
      if (attr === 'value' && window.Game.selectedActor) {
        window.Game.selectedActor.variableValues[id] = value;
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
      var _ref, _ref1;
      return ((_ref = window.Game) != null ? (_ref1 = _ref.selectedActor) != null ? _ref1.variableValue(id) : void 0 : void 0) || window.Game.selectedDefinition.variables()[id]['value'];
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
      id = ui.draggable.data('identifier');
      variable = window.Game.selectedDefinition.variables()[id];
      variable.x = left;
      variable.y = top;
      return window.Game.selectedDefinition.save();
    };
  };

  window.VariablesCtrl = VariablesCtrl;

}).call(this);
