VariablesCtrl = ($scope) ->

  window.variablesScope = $scope

  $scope.var_width = 90
  $scope.var_height = 80

  $scope.variables = () ->
    window.Game?.selectedDefinition?.variables()

  $scope.add_variable = () ->
    window.Game?.selectedDefinition.addVariable()
    window.Game?.selectedDefinition.save()

  $scope.variable_clicked = (variable) ->
    if window.Game.tool == 'delete'
      definition = window.Game?.selectedDefinition
      if confirm("Are you sure you want to delete the variable '#{variable.name}'? When you delete the variable, it will be deleted from all '#{definition.name}'.")
        definition.removeVariable(variable)
        definition.save()
    window.Game.resetToolAfterAction()

  $scope.edit_variable_attr = (event, attr) ->
    variableEl = $(event.target).parent()
    id = variableEl.data('identifier')
    variableEl.find("div").css('display', 'none')
    variableEl.find("input").css('display', 'inherit')
    variableEl.find("input.#{attr}").focus()

  $scope.save_variable_attr = (event, attr) ->
    variableEl = $(event.target).parent()
    id = variableEl.data('identifier')['variable:'.length..-1]
    value = $(event.target).val()

    value = 'Untitled' if value?.length == 0 && attr = 'name'

    if attr == 'value' && window.Game.selectedActor
      window.Game.onActorVariableValueEdited(window.Game.selectedActor, id, value)
    else
      definition = window.Game.selectedDefinition
      definition.variables()[id][attr] = value
      definition.save()

    variableEl.find("div").css('display', 'inherit')
    variableEl.find("input").css('display', 'none')
    variableEl.find("div.#{attr}").text(value)

  $scope.value_for_variable = (id) ->
    return window.Game.selectedDefinition.variables()[id]['value'] unless window.Game?.selectedActor
    window.Game.selectedActor.variableValue(id)

  $scope.css_for_variable = (variable) ->
    "left:#{variable.x * $scope.var_width}px; top:#{variable.y * $scope.var_height}px;"

  $scope.ondrop = (event, ui) ->
    maxLeft = ($(event.target).innerWidth() - ui.draggable.outerWidth()) / $scope.var_width
    maxTop = ($(event.target).innerHeight() - ui.draggable.outerHeight()) / $scope.var_height

    left = Math.round(ui.draggable.css('left').replace('px','') / $scope.var_width)
    left = Math.max(0, Math.min(maxLeft, left))
    top = Math.round(ui.draggable.css('top').replace('px','') / $scope.var_height)
    top = Math.max(0, Math.min(maxTop, top))

    ui.draggable.css('left', "#{left * $scope.var_width}px");
    ui.draggable.css('top', "#{top * $scope.var_height}px");

    id = ui.draggable.data('identifier')['variable:'.length..-1]
    variable = window.Game.selectedDefinition.variables()[id]
    variable.x = left
    variable.y = top
    window.Game.selectedDefinition.save()


window.VariablesCtrl = VariablesCtrl