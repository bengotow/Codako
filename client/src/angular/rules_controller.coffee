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

window.RulesCtrl = RulesCtrl