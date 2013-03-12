RulesCtrl = ($scope) ->

  $scope.rules = () ->
    return [] unless $scope.Manager && $scope.Manager.level.selectedDefinition
    $scope.Manager.level.selectedDefinition.rules

  $scope.scenario_before_url = (rule) ->
    window.Game.Manager.renderRuleScenario(rule.scenario)

  $scope.scenario_after_url = (rule) ->
    window.Game.Manager.renderRuleScenario(rule.scenario, true)

window.RulesCtrl = RulesCtrl