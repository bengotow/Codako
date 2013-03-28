(function() {
  var VariablesCtrl;

  VariablesCtrl = function($scope) {
    window.variablesScope = $scope;
    $scope.variables = function() {
      var _ref, _ref1, _ref2, _ref3;
      return ((_ref = window.Game) != null ? (_ref1 = _ref.selectedActor) != null ? _ref1.variables() : void 0 : void 0) || ((_ref2 = window.Game) != null ? (_ref3 = _ref2.selectedDefinition) != null ? _ref3.variables() : void 0 : void 0);
    };
    $scope.add_variable = function() {
      var _ref;
      return (_ref = window.Game) != null ? _ref.selectedDefinition.addVariable() : void 0;
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
    return $scope.save_variable_attr = function(event, attr) {
      var definition, identifier;
      identifier = $(event.target).data('identifier');
      definition = window.Game.selectedDefinition;
      definition.variables()[identifier][attr] = $(event.target).val();
      return definition.save();
    };
  };

  window.VariablesCtrl = VariablesCtrl;

}).call(this);
