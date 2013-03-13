class ProgrammableSprite extends Sprite

  MoveAcceleration = 13000.0
  GroundDragFactor = 0.48
  MaxMoveSpeed = 1750.0

  constructor: (identifier, position, size, level) ->
    @identifier = identifier
    @definition = undefined
    @currentFrame = 66

    super(position, size, level)
    @setupDragging()
    @

  descriptor: () ->
    {
      identifier: @identifier,
      position: {x: @worldPos.x, y: @worldPos.y},
      appearance: @appearance
    }

  matchesDescriptor: (descriptor) ->
    id_match = @identifier == descriptor.identifier
    appearance_match = @appearance == descriptor.appearance
    return id_match && (appearance_match || !descriptor.appearance)


  setAppearance: (name) ->
    return unless @definition.hasAppearance(name)
    @appearance = name
    @gotoAndStop(name)


  reset: (position) ->
    super(position)
    @gotoAndStop(@appearance)


  tick: (elapsed) ->
    return if @dragging
    super


  tickRules: () ->
    return unless @definition
    for rule in @definition.rules
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


  # -- drag and drop --- #

  setupDragging: () ->
    @dragging = false
    @addEventListener 'mousedown', (e) =>
      grabX = e.stageX - @x
      grabY = e.stageY - @y
      @alpha = 0.5
      @dragging = true

      e.addEventListener 'mousemove', (e) =>
        @x = e.stageX - grabX
        @y = e.stageY - grabY
      e.addEventListener 'mouseup', (e) =>
        p = new Point(Math.round(@x / Tile.WIDTH), Math.round(@y / Tile.HEIGHT))
        @dropped(p)


  dropped: (point) ->
    # overridden to add other drop behavior
    @worldPos = @nextPos = point
    @dragging = false
    @alpha = 1
    @level.onActorDragged(@)


window.ProgrammableSprite = ProgrammableSprite
