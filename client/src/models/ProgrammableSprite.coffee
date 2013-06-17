class ProgrammableSprite extends Sprite

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
    return id_match && (appearance_match || !descriptor.appearance)


  setAppearance: (identifier = 'idle') ->
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
      return false unless window.Game.actorsAtPositionMatchDescriptors(pos, descriptors)
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
    for action in rule.actions
      descriptor = rule.descriptors[action.ref]
      pos = Point.sum(@worldPos, Point.fromString(descriptor.offset))
      pos = @stage.wrappedPosition(pos) if @stage
      actor = window.Game.actorMatchingDescriptor(descriptor, window.Game.actorsAtPosition(pos))
      if actor
        actor.applyRuleAction(action)
      else
        actor = window.Game.addActor(descriptor, pos)


  applyRuleAction: (action) ->
    return unless action
    if action.type == 'move'
      p = Point.sum(@worldPos, Point.fromString(action.delta))
      p = @stage.wrappedPosition(p) if @stage
      @setWorldPos(p)

    if action.type == 'deleted'
      @stage.removeActor(@) if @stage
      @setWorldPos(-100,-100)

    if action.type == 'appearance'
      @setAppearance(action.after)

    if action.type == 'variable-incr'
      @variableValues[action.id] = @variableValue(action.id) + action.increment / 1

    if action.type == 'variable-set'
      @variableValues[action.id] = action.after / 1


  computeActionsToBecome: (after) =>
    actions = []
    if !after
      actions.push({type:'deleted'})
      return actions

    # if it is, let's declare changes...
    if @worldPos.x != after.worldPos.x || @worldPos.y != after.worldPos.y
      dx = after.worldPos.x - @worldPos.x
      dy = after.worldPos.y - @worldPos.y
      actions.push({type:'move', delta: "#{dx},#{dy}"})

    if @appearance != after.appearance
      actions.push({type:'appearance', after: after.appearance})

    for id, variable of @definition.variables()
      b = @variableValue(id)
      a = after.variableValue(id)
      console.log('Rule:', a,b)
      continue if a == b
      if Math.abs(a - b) == 1
        actions.push({type:'variable-incr', id: id, increment: a-b})
      else
        actions.push({type:'variable-set', id: id, after: a})

    return undefined if actions.length == 0
    actions


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


window.ProgrammableSprite = ProgrammableSprite
