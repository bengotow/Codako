RulesCtrl = ($scope) ->

  $scope.rule_structs_lookup_table = null

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


  $scope.sortable_attributes_for_rules_root = () ->
    rules = $scope.rules()
    if rules.length > 0 && rules[0].type == 'group-event'
      {}
    else
      {"connectWith":".rules-list"}


  $scope.sortable_change_start = () ->
    $scope.rule_structs_lookup_table = {}
    for struct in $scope.rules()
      $scope.populate_structs_lookup_table(struct)


  $scope.sortable_contents_changed = (event, ui) ->
    for key, struct of $scope.rule_structs_lookup_table
      $scope.recompute_struct_contents(key) if struct.rules
    $scope.Manager.level.selectedDefinition.save()


  $scope.recompute_struct_contents = (container_id) ->
    container_el = $("[data-id='#{container_id}']")
    child_els = container_el.find('ul').first().children('[data-id]')

    child_ids = []
    child_ids.push($(child).data('id')) for child in child_els

    # empty and refill this item in our tree
    container = $scope.rule_structs_lookup_table[container_id]
    container.rules.length = 0
    container.rules.push($scope.rule_structs_lookup_table[id]) for id in child_ids


  $scope.populate_structs_lookup_table = (struct) ->
    $scope.rule_structs_lookup_table[$scope.id_for_struct(struct)] = struct
    if struct.rules
      for rule in struct.rules
        $scope.populate_structs_lookup_table(rule)


  $scope.id_for_struct = (struct) ->
    return unless struct
    struct._id ||= Math.floor((1 + Math.random()) * 0x10000).toString(6)
    struct._id


  $scope.actions_for_rule = (rule) ->
    actions = []
    for block in rule.scenario
      for descriptor in block.descriptors
        for action in descriptor.actions
          actions.push({identifier: descriptor.identifier, action})
    actions


window.RulesCtrl = RulesCtrl