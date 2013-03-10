class ProgrammableSprite extends Sprite

  MoveAcceleration = 13000.0
  GroundDragFactor = 0.48
  MaxMoveSpeed = 1750.0

  constructor: (identifier, position, size, level) ->
    @identifier = identifier
    @rules = []
    @currentFrame = 66

    super(position, size, level)
    @


  reset: (position) ->
    super(position)
    @gotoAndPlay "idle"


  tick: (elapsed) ->
    super

  tickRules: () ->
    return unless @rules
    for rule in @rules
      if @checkTriggers(rule.triggers) && @checkScenario(rule.scenario)
        @applyScenario(rule.scenario)


  checkScenario: (scenario) ->
    for block in scenario
      pos = Point.sum(@worldPos, Point.fromString(block.coord))
      descriptors = block.descriptors
      return false unless @level.actorsAtPositionMatchDescriptors(pos, descriptors)
    true


  checkTriggers: (triggers) ->
    for trigger in triggers
      if trigger.type == 'key'
        return false unless @level.isKeyDown(trigger.code)
    true

  applyScenario: (scenario) ->
    for block in scenario
      pos = Point.sum(@worldPos, Point.fromString(block.coord))
      continue unless block.descriptors
      for descriptor in block.descriptors
        continue unless descriptor.actions
        actor = @level.actorMatchingDescriptor(pos, descriptor)
        actor.applyActions(descriptor.actions) if actor


  applyActions: (actions) ->
    return unless actions
    for action in actions
      if action.type == 'move'
        @nextPos = Point.sum(@worldPos, Point.fromString(action.delta))



window.ProgrammableSprite = ProgrammableSprite
