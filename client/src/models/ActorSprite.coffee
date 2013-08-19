class ActorSprite extends Sprite

  constructor: (identifier, position, size) ->
    @identifier = identifier
    @stage = undefined
    @definition = undefined
    @currentFrame = 66
    @clickedInCurrentFrame = false
    @variableValues = {}
    @applied = {}

    super(position, size)
    @setupDragging()
    @


  variableValue: (id) ->
    val = @variableValues?[id] || @definition.variables()[id]['value']
    val / 1


  descriptor: () ->
    {
      _id: @_id
      identifier: @identifier,
      position: {x: @worldPos.x, y: @worldPos.y},
      appearance: @appearance,
      variableValues: @variableValues
    }

  matchesDescriptor: (descriptor) ->
    id_match = @identifier == descriptor.identifier
    appearance_match = @appearance == descriptor.appearance
    variable_failed = false
    for id, constraint of descriptor.variableConstraints
      value = @variableValue(id)
      variable_failed = true if constraint.comparator == '=' && value != constraint.value
      variable_failed = true if constraint.comparator == '>' && value <= constraint.value
      variable_failed = true if constraint.comparator == '<' && value >= constraint.value

    return id_match && !variable_failed && (appearance_match || !descriptor.appearance)


  setAppearance: (identifier = 'idle') ->
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

      # don't stop, apply next rule
      return false

    else
      for rule in rules
        @tickRule(rule)
        return @applied[struct._id] = true if @applied[rule._id]

    # stop applying rules if we applied a rule
    return @applied[struct._id]


  tickRule: (rule) ->
    if rule.type == 'group-event'
      if @checkEvent(rule)
        @applied[rule._id] = true
        @tickRules(rule, 'first')

    else if rule.type == 'group-flow'
      @applied[rule._id] = @tickRules(rule, rule.behavior)

    else if @checkRuleScenario(rule)
      @applied[rule._id] = true
      @applyRule(rule)

    else
      @applied[rule._id] = false

    @applied[rule._id]


  checkRuleScenario: (rule) ->
    for block in rule.scenario
      pos = Point.sum(@worldPos, Point.fromString(block.coord))
      descriptors = _.map block.refs, (ref) -> rule.descriptors[ref]
      return false unless @stage.actorsAtPositionMatchDescriptors(pos, descriptors)
    true


  checkEvent: (trigger) ->
    if trigger.event == 'key'
      if window.Game.isKeyDown(trigger.code)
        return true
    if trigger.event == 'click'
      return @clickedInCurrentFrame
    if trigger.event == 'idle'
      return true
    false


  applyRule: (rule) ->
    rootPos = new Point(@worldPos.x, @worldPos.y)

    for action in rule.actions
      descriptor = rule.descriptors[action.ref]
      offset = action.offset || rule.scenarioOffsetOf(action.ref)
      pos = Point.sum(rootPos, Point.fromString(offset))
      pos = @stage.wrappedPosition(pos) if @stage
      actor = @stage.actorMatchingDescriptor(descriptor, @stage.actorsAtPosition(pos))

      if action.type == 'create'
        actor = @stage.addActor(descriptor, pos)
        actor._id = Math.createUUID()
      else if actor
        actor.applyRuleAction(action)
      else
        throw "Couldn't find the actor for performing rule: #{rule}"


  applyRuleAction: (action) ->
    return unless action
    if action.type == 'move'
      p = Point.sum(@worldPos, Point.fromString(action.delta))
      p = @stage.wrappedPosition(p) if @stage
      @setWorldPos(p)

    else if action.type == 'delete'
      @stage.removeActor(@) if @stage
      @setWorldPos(-100,-100)

    else if action.type == 'appearance'
      @setAppearance(action.to)

    else if action.type == 'variable'
      current = @variableValue(action.variable)
      @variableValues[action.variable] = Math.applyOperation(current, action.operation, action.value)

    else
      console.log('Not sure how to apply action', action)



  # -- drag and drop --- #

  setupDragging: () ->
    @dragging = false
    @addEventListener 'mousedown', (e) =>
      return unless @stage.draggingEnabled
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
    @dragging = false
    @alpha = 1
    window.Game.onActorDragged(@, @stage, point)


window.ActorSprite = ActorSprite
