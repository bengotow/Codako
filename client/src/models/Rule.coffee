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
    for key,obj of @descriptors
      obj = JSON.parse(JSON.stringify(obj))
      [offsetX, offsetY] = obj.offset.split(',')
      obj.position = {x: worldPadX + offsetX/1, y: worldPadY + offsetY/1}
      data.actor_descriptors.push(obj)

    data

  findActorReference: (actor) ->
    # The actor_id_during_recording property is important because the actor may
    # be moved arbitrarily so that it no longer matches it's original descriptor,
    # and the actors don't keep their pre-change state.
    _.find Object.keys(@descriptors), (key) =>
      @descriptors[key].actor_id_during_recording == actor._id


  addActorReference: (actor) ->
    struct = actor.descriptor()
    struct.actor_id_during_recording = actor._id
    struct.offset = "#{actor.worldPos.x - @extentRoot.x},#{actor.worldPos.y - @extentRoot.y}"
    struct.variableConstraints = {}
    for variable, value of struct.variableValues
      struct.variableConstraints[variable] = {value: value, comparator: "="}

    delete struct._id
    delete struct.position
    delete struct.variableValues

    uuid = Math.createUUID()
    @descriptors[uuid] = struct
    return uuid


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
          ref = @addActorReference(actor) unless ref
          block.refs.push(ref)
          delete unused[ref]

    delete @descriptors[ref] for ref,descriptor of unused


  updateActions: (beforeStage, afterStage) =>
    @withEachActor beforeStage, afterStage, (ref, beforeActor, afterActor) =>
      # okay - so we have the before and after state of this actor. Now we need to
      # review and adjust the actions we have, creating new ones if necessary to reach
      # the after state. Yes, the code below actually creates actions for everything
      # and then destroys the ones it doesn't need. It's simpler to follow that way.

      [action, actionIndex] = @actionFor(ref, 'appearance')
      action['to'] = afterActor.appearance
      if beforeActor.appearance == afterActor.appearance
        @actions.splice(actionIndex, 1)


      [action, actionIndex] = @actionFor(ref, 'move')
      action.delta = "#{afterActor.worldPos.x - beforeActor.worldPos.x},#{afterActor.worldPos.y - beforeActor.worldPos.y}"
      if action.delta == "0,0"
        @actions.splice(actionIndex, 1)


      for vID in beforeActor.definition.variableIDs()
        before = beforeActor.variableValue(vID)
        after = afterActor.variableValue(vID)

        [action, actionIndex] = @actionFor ref, 'variable', (action) -> action.variable == vID

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



  extentRelativeToRoot: () =>
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


  extentOnStage: () =>
    extent = @extentRelativeToRoot()
    extent.left += @extentRoot.x
    extent.right += @extentRoot.x
    extent.top += @extentRoot.y
    extent.bottom += @extentRoot.y
    extent


  descriptor: () =>
    {
      _id: @_id
      name: @name
      scenario: @scenario
      descriptors: @descriptors
      actions: @actions
    }


  actionFor: (uuid, type, extras = null) =>
    resultIndex = null
    for x in [@actions.length - 1..0] by -1
      action = @actions[x]
      if action.ref == uuid && action.type == type && (!extras || extras(action))
        result = action
        resultIndex = x

    if !result
      result = {ref: uuid, type: type, unsaved: true}
      resultIndex = @actions.length
      @actions.push(result)

    return [result, resultIndex]


  withEachActor: (beforeStage, afterStage, callback) =>
    extent = @extentOnStage()
    actorsSeen = {}

    # iterate over our region in the "before" scene. For each actor we find, look up it's reference
    # in the descriptors table and find it's match in the "after" scene.
    for x in [extent.left..extent.right]
      for y in [extent.top..extent.bottom]
        for beforeActor in beforeStage.actorsAtPosition(new Point(x,y))
          ref = @findActorReference(beforeActor) || @addActorReference(changeActor)
          afterActor = afterStage.actorWithID(@descriptors[ref].actor_id_during_recording)
          callback(ref, beforeActor, afterActor)
          actorsSeen[ref] = true

    # Since there may be actors in the after scene not in the before scene, scan through the "after"
    # scene separately and call those with FALSE as the "before" actor.
    for x in [extent.left..extent.right]
      for y in [extent.top..extent.bottom]
        for afterActor in afterStage.actorsAtPosition(new Point(x,y))
          ref = @findActorReference(beforeActor) || @addActorReference(changeActor)
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

