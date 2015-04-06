class Rule

  constructor: (json) ->
    @_id = Math.createUUID()
    @name = 'Untitled Rule'
    @scenario = []
    @descriptors = {}
    @actions = []
    @editing = false
    @[key] = value for key, value of json
    @extentRoot = new Point(0,0)


  setMainActor: (actor) ->
    @extentRoot = new Point(actor.worldPos.x, actor.worldPos.y)
    @actor = actor

  mainActorDescriptor: ->
    for key, descriptor of @descriptors
      return descriptor if descriptor.mainActor == true

    throw "Rule has no decriptor for it's main actor?"


  beforeSaveData: (worldPadX, worldPadY) ->
    extent = @extentRelativeToRoot()
    data = {
      identifier: 'before-rule'
      width: (extent.right - extent.left) + worldPadX*2,
      height: (extent.bottom - extent.top) + worldPadY*2,
      wrapX: true,
      wrapY: true,
      extent: {top: extent.top + worldPadY, left: extent.left + worldPadX, right: extent.right + worldPadX, bottom: extent.bottom + worldPadY}
      actor_descriptors: []
    }

    for block in @scenario
      for ref in block.refs
        [x,y] = block.coord.split(',')
        descriptor = JSON.parse(JSON.stringify(@descriptors[ref]))
        descriptor.position = {x: worldPadX + x/1, y: worldPadY + y/1}
        data.actor_descriptors.push(descriptor)

    data


  findActorReference: (actor) ->
    # The actor_id_during_recording property is important because the actor may
    # be moved arbitrarily so that it no longer matches it's original descriptor,
    # and the actors don't keep their pre-change state.
    _.find Object.keys(@descriptors), (key) =>
      @descriptors[key].actor_id_during_recording == actor._id


  addActorReference: (actor, options = {}) ->
    struct = actor.descriptor()
    struct.actor_id_during_recording = actor._id
    struct.appearance_ignored = true
    @updateActorReference(struct, actor)

    ref = Math.createUUID()
    @descriptors[ref] = struct
    return ref


  updateActorReference: (struct, actor) ->
    struct.appearance = actor.appearance
    struct.mainActor = actor == @actor

    struct.variableConstraints ||= {}
    for vID, obj of actor.definition.variables()
      value = actor.variableValue(vID)
      constraint = struct.variableConstraints[vID]
      if constraint
        constraint.value = value/1 if constraint.comparator == '=' && value != constraint.value
        constraint.value = value/1-1 if constraint.comparator == '>' && value < constraint.value
        constraint.value = value/1+1 if constraint.comparator == '<' && value > constraint.value
      else
        constraint = {value: value, comparator: "=", ignored: true}
      struct.variableConstraints[vID] = constraint

    delete struct._id
    delete struct.position
    delete struct.variableValues
    struct


  updateScenario: (stage, extent = null) =>
    extent = @extentOnStage() unless extent
    unused = Object.keys(@descriptors)
    @scenario = []

    for x in [extent.left..extent.right]
      for y in [extent.top..extent.bottom]
        block = {coord:"#{x - @extentRoot.x},#{y - @extentRoot.y}", refs: []}
        @scenario.push(block)

        for actor in stage.actorsAtPosition(new Point(x,y))
          ref = @findActorReference(actor)
          if ref
            @updateActorReference(@descriptors[ref], actor)
          else
            ref = @addActorReference(actor)

          block.refs.push(ref)
          delete unused[ref]

    delete @descriptors[ref] for ref,descriptor of unused


  updateActions: (beforeStage, afterStage, options = {}) =>

    @withEachActorInExtent beforeStage, afterStage, (ref, beforeActor, afterActor) =>
      # okay - so we have the before and after state of this actor. Now we need to
      # review and adjust the actions we have, creating new ones if necessary to reach
      # the after state. Yes, the calls to actionFor create actions for everything
      # and then this destroys the ones it doesn't need. It's simpler to follow that way.
      definition = beforeActor?.definition || afterActor?.definition
      created = !beforeActor
      deleted = !afterActor

      unless options.skipAppearance == true
        [action, actionIndex, actionIsNew] = @actionFor(ref, 'appearance')
        if created || deleted || beforeActor.appearance == afterActor.appearance || (actionIsNew && options.existingActionsOnly)
          @actions.splice(actionIndex, 1)
        else
          action['to'] = afterActor.appearance


      unless options.skipMove == true
        [action, actionIndex, actionIsNew] = @actionFor(ref, 'move')
        if created || deleted || afterActor.worldPos.isEqual(beforeActor.worldPos) || (actionIsNew && options.existingActionsOnly)
          @actions.splice(actionIndex, 1)
        else
          action.delta = "#{afterActor.worldPos.x - beforeActor.worldPos.x},#{afterActor.worldPos.y - beforeActor.worldPos.y}"


      unless options.skipCreate == true
        [action, actionIndex, actionIsNew] = @actionFor(ref, 'create')
        if !created || (actionIsNew && options.existingActionsOnly)
          @actions.splice(actionIndex, 1)
        else
          @updateActorReference(@descriptors[ref], afterActor)
          action.offset = "#{afterActor.worldPos.x - @extentRoot.x},#{afterActor.worldPos.y - @extentRoot.y}"


      unless options.skipDelete == true
        [action, actionIndex, actionIsNew] = @actionFor(ref, 'delete')
        if !deleted || (actionIsNew && options.existingActionsOnly)
          @actions.splice(actionIndex, 1)


      unless options.skipVariables == true
        for vID in definition.variableIDs()
          [action, actionIndex, actionIsNew] = @actionFor ref, 'variable', (action) -> action.variable == vID

          if created || deleted || (actionIsNew && options.existingActionsOnly)
            @actions.splice(actionIndex, 1)
            continue

          before = beforeActor.variableValue(vID)
          after = afterActor.variableValue(vID)

          action['variable'] = vID
          if ((after-before == 1) || (action.operation == 'add'))
            action['operation'] = 'add'
            action['value'] = after-before
          else if ((before - after == 1) || (action.operation == 'subtract'))
            action['operation'] = 'subtract'
            action['value'] = before-after
          else
            action['operation'] = 'set'
            action['value'] = after

          if before == after || action['value']/1 == 0
            @actions.splice(actionIndex, 1)


  updateExtent: (beforeStage, afterStage, desiredExtent) ->
    # ensure that all actors in the scenario are in the extent, both before and after
    extent = desiredExtent

    @withEachActorInExtent beforeStage, afterStage, (ref, beforeActor, afterActor) =>
      for actor in [beforeActor, afterActor]
        continue unless actor

        actorHasActions = false
        actorIsPrimary = actor == @actor
        for action in @actions
          actorHasActions = true if action.ref == ref

        continue unless actorHasActions || actorIsPrimary

        extent.left = Math.min(actor.worldPos.x, extent.left)
        extent.right = Math.max(actor.worldPos.x, extent.right)
        extent.top = Math.min(actor.worldPos.y, extent.top)
        extent.bottom = Math.max(actor.worldPos.y, extent.bottom)

    @updateScenario(beforeStage, extent)
    return extent


  extentRelativeToRoot: =>
    extent = {left: 10000, top: 10000, right: 0, bottom: 0}

    if !@scenario || @scenario.length == 0
      throw "Invalid rule - no scenario! Has no extent."

    # read the scenario definition
    for block in @scenario
      [x,y] = block.coord.split(',')
      extent.left = Math.min(x, extent.left)
      extent.right = Math.max(x, extent.right)
      extent.top = Math.min(y, extent.top)
      extent.bottom = Math.max(y, extent.bottom)
    extent


  extentOnStage: =>
    extent = @extentRelativeToRoot()
    extent.left += @extentRoot.x
    extent.right += @extentRoot.x
    extent.top += @extentRoot.y
    extent.bottom += @extentRoot.y
    extent


  descriptor: =>
    {
      _id: @_id
      name: @name
      scenario: @scenario
      descriptors: @descriptors
      actions: @actions
    }


  descriptors: =>
    @descriptors


  descriptorsInScenario: =>
    results = {}
    for block in @scenario
      for ref in block.refs
        results[ref] = @descriptors[ref]
    results


  scenarioOffsetOf: (searchRef) =>
    for block in @scenario
      for ref in block.refs
        return block.coord if ref == searchRef


  actionFor: (uuid, type, extras = null) =>
    resultIndex = null
    isNew = false
    for x in [@actions.length - 1..0] by -1
      action = @actions[x]
      if action.ref == uuid && action.type == type && (!extras || extras(action))
        result = action
        resultIndex = x

    if !result
      isNew = true
      result = {ref: uuid, type: type}
      resultIndex = @actions.length
      @actions.push(result)

    return [result, resultIndex, isNew]


  withEachActorInExtent: (beforeStage, afterStage, callback) =>
    extent = @extentOnStage()
    actorsSeen = {}

    # iterate over our region in the "before" scene. For each actor we find, look up it's reference
    # in the descriptors table and find it's match in the "after" scene.
    for x in [extent.left..extent.right]
      for y in [extent.top..extent.bottom]
        for beforeActor in beforeStage.actorsAtPosition(new Point(x,y))
          ref = @findActorReference(beforeActor) || @addActorReference(beforeActor)
          afterActor = afterStage.actorWithID(@descriptors[ref].actor_id_during_recording)
          callback(ref, beforeActor, afterActor)
          actorsSeen[ref] = true

    # Since there may be actors in the after scene not in the before scene, scan through the "after"
    # scene separately and call those with FALSE as the "before" actor.
    for x in [extent.left..extent.right]
      for y in [extent.top..extent.bottom]
        for afterActor in afterStage.actorsAtPosition(new Point(x,y))
          ref = @findActorReference(afterActor) || @addActorReference(afterActor)
          continue if actorsSeen[ref]
          callback(ref, false, afterActor)



Rule.inflateRules = (arr) ->
  rules = []
  return rules unless arr && arr instanceof Array

  for json in arr
    if json['type'] == "group-flow"
      rules.push(new FlowGroupRule(json))
    else if json['type'] == "group-event"
      rules.push(new EventGroupRule(json))
    else
      rules.push(new Rule(json))

  rules

Rule.deflateRules = (arr) ->
  rules = []
  return rules unless arr && arr instanceof Array

  for rule in arr
    rules.push(rule.descriptor())
  rules

window.Rule = Rule

