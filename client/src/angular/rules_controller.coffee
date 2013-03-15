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

  $scope.name_for_key = (code) ->
    return "Space Bar" if code == 32
    return "Up Arrow" if code == 38
    return "Left Arrow" if code == 37
    return "Right Arrow" if code == 39
    return String.fromCharCode(code)

  $scope.name_for_event_group = (struct) ->
    if struct.event == 'key'
      return "When the #{$scope.name_for_key(struct.code)} Key is Pressed"
    else if struct.event = 'click'
      return "When I'm Clicked"
    else
      return "When I'm Idle"

  $scope.name_for_flow_group = (struct) ->
    return "Flow Group"

  $scope.actions_for_rule = (rule) ->
    actions = []
    for block in rule.scenario
      for descriptor in block.descriptors
        for action in descriptor.actions
          actions.push({identifier: descriptor.identifier, action})
    actions


window.RulesCtrl = RulesCtrl