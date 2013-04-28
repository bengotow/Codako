class Rule

  constructor: (actor) ->
    @_id = Math.createUUID()
    @name = 'Untitled Rule'
    @scenario = []
    @descriptors = {}
    @actor = actor
    @actions = []
    @editing = false


  prepareForEditing: () ->
    # this code needs to iterate through the blocks in the scenario, find
    # actor instances on the game stage that match the descriptors for that block,
    # and bind them together using actor_id_during_recording.

    # The actor_id_during_recording property is important because the actor may
    # be moved arbitrarily so that it no longer matches it's original descriptor,
    # and the actors don't keep their pre-change state.


  findActorReference: (actor) ->
    _.find Object.keys(@descriptors), (key) =>
      @descriptors[key].actor_id_during_recording == actor._id


  addActorReference: (actor) ->
    struct = actor.descriptor()
    struct.actor_id_during_recording = actor._id
    struct.offset = "#{actor.worldPos.x - @actor.worldPos.x},#{actor.worldPos.y - @actor.worldPos.y}"
    struct.variableConstraints = {}
    for variable, value of struct.variableValues
      struct.variableConstraints[variable] = {value: value, comparator: "="}

    delete struct._id
    delete struct.position
    delete struct.variableValues

    uuid = Math.createUUID()
    @descriptors[uuid] = struct
    return uuid


  updateScenario: (stage, extent) =>
    existingScenario = @scenario
    unusedDescriptors = _.clone(@descriptors)
    @scenario = []

    for x in [extent.left..extent.right]
      for y in [extent.top..extent.bottom]
        coord = "#{x - @actor.worldPos.x},#{y - @actor.worldPos.y}"
        block = _.find existingScenario, (block) -> block.coord == coord

        if !block
          block = {coord:coord, refs: []}
          for actor in stage.actorsAtPosition(new Point(x,y))
            uuid = @addActorReference(actor)
            block.refs.push(uuid)

        delete unusedDescriptors[uuid] for uuid in block.refs
        @scenario.push(block)

    delete @descriptors[uuid] for uuid,value of unusedDescriptors


  save:() =>
    @actor.definition.addRule(@)

  actionMatching:(uuid, type, extras = null) =>
    existing = _.find @actions, (action) ->
      action.ref == uuid && action.type == type && (!extras || extras(action))
    existing || {ref: uuid, type: type, unsaved: true}


  incorporate: (changeActor, changeType, newValue = null) ->
    return unless @editing

    # look for the existing descriptor UUID that we're using for this actor
    refUUID = @findActorReference(changeActor) || @addActorReference(changeActor)
    refNotChanged = false

    # create a new action, or ammend an existing one
    if changeType == 'appearance'
      action = @actionMatching(refUUID, changeType)
      action['to'] = newValue

    else if changeType == 'variable'
      action = @actionMatching refUUID, changeType, (option) -> option.variable == newValue.variable
      before = changeActor.variableValue(newValue.variable)
      after = newValue.value

      action['variable'] = newValue.variable
      if ((after-before == 1) || (action.operation == 'add'))
        action['operation'] = 'add'
        action['value'] = after-before
      else if ((before - after == 1) || (action.operation == 'subtract'))
        action['operation'] = 'subtract'
        action['value'] = before-after
      else
        action['operation'] = 'set'
        action['value'] = after

      if action['value']/1 == 0
        refNotChanged = true

    else if changeType == 'move'
      # compute the delta between the previous position and the new position,
      # in the coordinate space relative to the root @actor of the Rule
      [refX, refY] = [@actor.worldPos.x, @actor.worldPos.y]
      [offsetX, offsetY] = @descriptors[refUUID].offset.split(',')
      action = @actionMatching(refUUID, changeType)
      action['delta'] = "#{newValue.x - (refX/1 + offsetX/1)},#{newValue.y - (refY/1 + offsetY/1)}"
      if action['delta'] == "0,0"
        refNotChanged = true

    # we've computed the action and it turns out it's a no-op.
    # Delete the action if it's already in the actions set
    if refNotChanged
      index = @actions.indexOf(action)
      @actions.splice(index, 1) if index != -1
      return

    if action.unsaved
      delete action['unsaved']
      @actions.push(action)


window.Rule = Rule
