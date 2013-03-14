RulesCtrl = ($scope) ->

  $scope.rules = () ->
    return [] unless $scope.Manager && $scope.Manager.level.selectedDefinition
    $scope.Manager.level.selectedDefinition.rules

  $scope.scenario_before_url = (rule) ->
    cache = $scope.Manager.level.selectedDefinition.ruleRenderCache
    cache["#{rule.name}-before"] ||= window.Game.Manager.renderRuleScenario(rule.scenario)
    cache["#{rule.name}-before"]

  $scope.scenario_after_url = (rule) ->
    cache = $scope.Manager.level.selectedDefinition.ruleRenderCache
    cache["#{rule.name}-after"] ||= window.Game.Manager.renderRuleScenario(rule.scenario, true)
    cache["#{rule.name}-after"]

  $scope.toggle_disclosed = (struct) ->
    if struct.disclosed
      delete struct.disclosed
    else
      struct.disclosed = 'disclosed'

  $scope.actions_for_rule = (rule) ->
    actions = []
    for block in rule.scenario
      for descriptor in block.descriptors
        for action in descriptor.actions
          actions.push({identifier: descriptor.identifier, action})
    actions


window.RulesCtrl = RulesCtrl