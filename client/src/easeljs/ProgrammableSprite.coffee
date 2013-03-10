class ProgrammableSprite extends Sprite

  MoveAcceleration = 13000.0
  GroundDragFactor = 0.48
  MaxMoveSpeed = 1750.0

  constructor: (position, size, level) ->
    @name = "Hero"
    @rules = []
    @currentFrame = 66

    super(position, size, level)
    @


  reset: (position) ->
    super(position)
    @gotoAndPlay "idle"


  tick: (elapsed) ->
    super

  applyRules: () ->
    return unless @rules
    for rule in @rules
      if @checkTriggers(rule.triggers) && @checkConditions(rule.conditions)
        @applyRuleActions(rule.actions)
        console.log("Executed Rule #{rule.name}")

  checkConditions: (conditions) ->
    for condition in conditions
      if condition.type == 'surroundings'
        pos = @positionForRelativeCoordinates(condition.coord)
        descriptors = condition.descriptors
        return false unless @level.actorsAtPositionMatchDescriptors(pos, descriptors)
      else
        return false
    true

  checkTriggers: (triggers) ->
    for trigger in triggers
      if trigger.type == 'key'
        return false unless @level.isKeyDown(trigger.code)
    true


  applyRuleActions: (actions) ->
    for action in actions
      if action.type == 'move'
        start = @positionForRelativeCoordinates(action.start)
        end = @positionForRelativeCoordinates(action.end)

        actors = @level.actorsAtPosition(start)
        actor.nextPos = end for actor in actors
        console.log('MOVE: ', start, end, actors)


  positionForRelativeCoordinates: (str) ->
    coords = str.split(',')
    debugger
    new Point(coords[0] / 1 + @worldPos.x, coords[1] / 1 + @worldPos.y)


window.ProgrammableSprite = ProgrammableSprite
