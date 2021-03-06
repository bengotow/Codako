RulesCtrl = ($scope) ->

  window.rulesScope = $scope

  $scope.structs_lookup_table = null
  $scope.flow_types =
    'Do First Match': 'first'
    'Do All & Continue': 'all'
    'Randomize & Do First': 'random'

  $scope.definition_name = ->
    return undefined unless window.Game && window.Game.selectedDefinition
    window.Game.selectedDefinition.name


  $scope.rules = ->
    return undefined unless window.Game && window.Game.selectedDefinition
    window.Game.selectedDefinition.rules


  $scope.add_rule = ->
    window.Game.editNewRuleForActor(window.Game.selectedActor)


  $scope.focus_rule_input = (event) ->
    if $(event.target).val().indexOf('Untitled') != -1
      $(event.target).select()
      $(event.target).mouseup (e)-> e.preventDefault()
      event.preventDefault()


  $scope.rule_clicked = (rule) ->
    if window.Game.tool == 'delete'
      if rule.event == 'idle'
        alert('Sorry, you can\'t remove the idle case!')
      else if confirm('Are you sure you want to delete this rule? You can\'t undo this action.')
        window.Game.selectedDefinition.removeRule(rule)
    window.Game.resetToolAfterAction()


  $scope.rule_dbl_clicked = (rule, event) ->
    if event.target.tagName == 'INPUT'
      #this event is directed to the name field of the rule
      return
    window.Game.editRule(rule, window.Game.selectedActor)


  $scope.add_rule_group_event = (type) ->
    if type == 'key'
      $scope.$root.$broadcast('edit_key', {key_code:false, completion_callback: $scope.add_rule_group_event_key})
    else
      window.Game.selectedDefinition.addEventGroup({event: type})


  $scope.add_rule_group_event_key = (key_code) =>
    window.Game.selectedDefinition.addEventGroup({event: 'key', code: key_code})


  $scope.add_rule_group_flow = ->
    window.Game.selectedDefinition.addFlowGroup()


  $scope.save_rules = ->
    window.Game.selectedDefinition.save()


  $scope.scenario_before_url = (rule) ->
    cache = window.Game.selectedDefinition.ruleRenderCache
    cache["#{rule._id}-before"] ||= window.Game.renderRule(rule)
    cache["#{rule._id}-before"] || ""


  $scope.scenario_after_url = (rule) ->
    cache = window.Game.selectedDefinition.ruleRenderCache
    cache["#{rule._id}-after"] ||= window.Game.renderRule(rule, true)
    cache["#{rule._id}-after"] || ""


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
    return String.fromEventKeyCode(code)


  $scope.name_for_event_group = (struct) ->
    if struct.event == 'key'
      return "When the <span class='keycode'>#{$scope.name_for_key(struct.code)} Key</span> is Pressed"
    else if struct.event == 'click'
      return "When I'm Clicked"
    else
      return "When I'm Idle"

  $scope.double_click_edit_event_group = (struct) ->
    if struct.event == 'key'
      $scope.$root.$broadcast 'edit_key',
        key_code:struct.code,
        completion_callback: (code) ->
          struct.code = code
          window.Game.selectedDefinition.save()



  $scope.name_for_flow_group = (struct) ->
    return "Flow Group"


  $scope.sortable_attributes_for_rules_root = ->
    rules = $scope.rules()
    return undefined unless rules
    if rules.length > 0 && rules[0].type == 'group-event'
      return "disabled"
    else
      return {'connectWith':'.rules-list'}


  $scope.sortable_change_start = ->
    $scope.structs_lookup_table = {}
    $scope.structs_lookup_table['base'] = {rules: $scope.rules()}
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

    # empty this struct's rule set and add rules by ID
    container = $scope.structs_lookup_table[container_id]
    container.rules.length = 0

    for id in child_ids
      child_struct = $scope.structs_lookup_table[id]

      # our approach is great, except for the fact that the root rules() array
      # is not a struct, so it never gets rebuilt when you sort something from
      # the root into a subtree. To account for this, let's just remove the item
      # from the rules array if we find it's a root item.
      root_index = $scope.rules().indexOf(child_struct)
      $scope.rules().splice(root_index, 1) if root_index >= 0

      container.rules.push(child_struct)


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
    #       actions.push({identifier: descriptor._id, action})
    # actions


window.RulesCtrl = RulesCtrl