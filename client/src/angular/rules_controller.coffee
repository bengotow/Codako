RulesCtrl = ($scope) ->

  window.rulesScope = $scope

  $scope.structs_lookup_table = null
  $scope.flow_types =
    'Do First Match': 'first'
    'Do All & Continue': 'all'
    'Randomize & Do First': 'random'

  $scope.definition_name = () ->
    return undefined unless window.Game && window.Game.selectedDefinition
    window.Game.selectedDefinition.name

  $scope.rules = () ->
    return undefined unless window.Game && window.Game.selectedDefinition
    window.Game.selectedDefinition.rules

  $scope.add_rule = () ->
    rule = {}
    $scope.$root.$broadcast('compose_rule', {actor: window.Game.selectedActor, rule: rule})

  $scope.save_rules = () ->
    window.Game.selectedDefinition.save()


  $scope.scenario_before_url = (rule) ->
    cache = window.Game.selectedDefinition.ruleRenderCache
    cache["#{rule.name}-before"] ||= window.Game.renderRuleScenario(rule.scenario)
    cache["#{rule.name}-before"]


  $scope.scenario_after_url = (rule) ->
    cache = window.Game.selectedDefinition.ruleRenderCache
    cache["#{rule.name}-after"] ||= window.Game.renderRuleScenario(rule.scenario, true)
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
    else if struct.event == 'click'
      return "When I'm Clicked"
    else
      return "When I'm Idle"


  $scope.name_for_flow_group = (struct) ->
    return "Flow Group"


  $scope.sortable_attributes_for_rules_root = () ->
    rules = $scope.rules()
    return undefined unless rules
    if rules.length > 0 && rules[0].type == 'group-event'
      return {}
    else
      return {"connectWith":".rules-list"}


  $scope.sortable_change_start = () ->
    $scope.structs_lookup_table = {}
    for struct in $scope.rules()
      $scope.populate_structs_lookup_table(struct)


  $scope.sortable_contents_changed = (event, ui) ->
    for key, struct of $scope.structs_lookup_table
      $scope.recompute_struct_contents(key) if struct.rules
    window.Game.selectedDefinition.save()


  $scope.recompute_struct_contents = (container_id) ->
    container_el = $("[data-id='#{container_id}']")
    child_els = container_el.find('ul').first().children('[data-id]')

    child_ids = []
    child_ids.push($(child).data('id')) for child in child_els

    # empty and refill this item in our tree
    container = $scope.structs_lookup_table[container_id]
    container.rules.length = 0
    container.rules.push($scope.structs_lookup_table[id]) for id in child_ids


  $scope.populate_structs_lookup_table = (struct) ->
    $scope.structs_lookup_table[struct._id] = struct
    if struct.rules
      for rule in struct.rules
        $scope.populate_structs_lookup_table(rule)


  $scope.circle_for_rule = (struct) ->
    actor = window.Game?.selectedActor
    return 'circle' unless struct && actor
    return 'circle true' if actor.applied[struct._id]
    return 'circle false'

  $scope.actions_for_rule = (rule) ->
    actions = []
    # for block in rule.scenario
    #   for descriptor in block.descriptors
    #     for action in descriptor.actions
    #       actions.push({identifier: descriptor.identifier, action})
    # actions


window.RulesCtrl = RulesCtrl