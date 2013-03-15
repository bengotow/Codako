class ProgrammableSprite extends Sprite

  MoveAcceleration = 13000.0
  GroundDragFactor = 0.48
  MaxMoveSpeed = 1750.0

  constructor: (identifier, position, size, level) ->
    @identifier = identifier
    @definition = undefined
    @currentFrame = 66
    @applied = {}

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


  setAppearance: (identifier) ->
    console.log 'Set appearance', identifier
    return unless @definition.hasAppearance(identifier)
    @appearance = identifier
    @gotoAndStop(@appearance)


  reset: (position) ->
    super(position)
    @gotoAndStop(@appearance)


  tick: (elapsed) ->
    return if @dragging
    super


  resetRulesApplied: () ->
    @applied = {}


  tickRules: (struct = @definition, behavior = 'first') ->
    rules = struct.rules
    rules = _.shuffle(rules) if behavior == 'random'

    if behavior == 'all'
      for rule in rules
        @tickRule(rule)
        @applied[struct._id] ||= @applied[rule._id]
    else
      for rule in rules
        @tickRule(rule)
        return @applied[struct._id] = true if @applied[rule._id]

    @applied[struct._id]


  tickRule: (rule) ->
    if rule.type == 'group-event'
      if @checkEvent(rule)
        @applied[rule._id] = true
        @tickRules(rule, 'first')

    else if rule.type == 'group-flow'
      @applied[rule._id] = @tickRules(rule, rule.behavior)

    else if @checkScenario(rule.scenario)
      @applied[rule._id] = true
      @applyScenario(rule.scenario)

    else
      @applied[rule._id] = false

    @applied[rule._id]


  checkScenario: (scenario) ->
    for block in scenario
      pos = Point.sum(@worldPos, Point.fromString(block.coord))
      descriptors = block.descriptors
      return false unless @level.actorsAtPositionMatchDescriptors(pos, descriptors)
    true


  checkEvent: (trigger) ->
    if trigger.event == 'key'
      if @level.isKeyDown(trigger.code)
        debugger
        return true
    if trigger.event == 'idle'
      return true
    false


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
        @nextPos = Point.sum(@nextPos, Point.fromString(action.delta))


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
