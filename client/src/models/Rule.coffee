class Rule

  constructor: (actor) ->
    @_id = Math.createUUID()
    @name = 'Untitled Rule'
    @scenario = []
    @descriptors = {}
    @actor = actor
    @actions = []
    @editing = false
    @checks = []


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
    uuid = Math.createUUID()
    delete struct._id
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


  incorporate: (changeActor, changeType, newValue = null) ->
    return unless @editing

    # look for the existing descriptor UUID that we're using for this actor
    refUUID = @findActorReference(changeActor) || @addActorReference(changeActor)

    # create a new action, or ammend an existing one
    action = _.find @actions, (existing) -> existing.ref == refUUID && existing.type == changeType
    if !action
      action = {ref: refUUID, type: changeType }
      @actions.push(action)

    if changeType == 'appearance'
      action['to'] = newValue
    else if changeType == 'move'
      # compute the delta between the previous position and the new position,
      # in the coordinate space relative to the root @actor of the Rule
      [refX, refY] = [@actor.worldPos.x, @actor.worldPos.y]
      [offsetX, offsetY] = @descriptors[refUUID].offset.split(',')
      action['delta'] = "#{newValue.x - (refX/1 + offsetX/1)},#{newValue.y - (refY/1 + offsetY/1)}"


window.Rule = Rule
