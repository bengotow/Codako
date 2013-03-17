ComposeRuleCtrl = ($scope) ->

  $scope.actor = null
  $scope.rule = {}

  $scope.$root.$on 'compose_rule', (msg, args) ->
    $scope.actor = args.actor
    $scope.rule = args.rule
    $('#composeRuleModal').modal({show:true})

  $scope.scenario_before_url = (rule) ->
    window.Game.renderRuleScenario(rule.scenario)


  $scope.scenario_after_url = (rule) ->
    window.Game.renderRuleScenario(rule.scenario, true)



window.ComposeRuleCtrl = ComposeRuleCtrl