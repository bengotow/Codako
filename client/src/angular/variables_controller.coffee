VariablesCtrl = ($scope) ->

  window.variablesScope = $scope

  $scope.variables = () ->
    window.Game?.selectedActor?.variables() || window.Game?.selectedDefinition?.variables()

  $scope.add_variable = () ->
    window.Game?.selectedDefinition.addVariable()

  $scope.select_variable = (id) ->
    if window.Game.tool == 'delete'
      if confirm('Are you sure you want to delete this variable?')
        window.Game?.selectedDefinition.removeVariable(id)
    window.Game.resetToolAfterAction()

  $scope.save_variable_attr = (event, attr) ->
    identifier = $(event.target).data('identifier')
    definition = window.Game.selectedDefinition
    definition.variables()[identifier][attr] = $(event.target).val()
    definition.save()


window.VariablesCtrl = VariablesCtrl