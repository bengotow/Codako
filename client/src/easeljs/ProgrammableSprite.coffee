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
    @variableValues[id] || @definition.variables()[id]['value']


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


  applyScenario: (scenario) ->
    for block in scenario
      pos = Point.sum(@worldPos, Point.fromString(block.coord))
      if block.descriptors
        for descriptor in block.descriptors
          continue unless descriptor.actions
          actor = window.Game.actorMatchingDescriptor(descriptor, window.Game.actorsAtPosition(pos))
          actor.applyActions(descriptor.actions) if actor

      if block.added
        for descriptor in block.added
          descriptor = JSON.parse(JSON.stringify(descriptor))
          pos = @stage.wrappedPosition(pos) if @stage
          descriptor.position = pos
          actor = window.Game.addActor(descriptor)


  applyActions: (actions) ->
    return unless actions
    for action in actions
      if action.type == 'move'
        @nextPos = Point.sum(@nextPos, Point.fromString(action.delta))
        @nextPos = @stage.wrappedPosition(@nextPos) if @stage

      if action.type == 'deleted'
        @stage.removeActor(@) if @stage
        @nextPos = new Point(-100,-100)

      if action.type == 'appearance'
        @setAppearance(action.after)

      if action.type == 'variable-incr'
        @variableValues[action.id] = @variableValue(action.id) + action.increment / 1

      if action.type == 'variable-set'
        @variableValues[action.id] = action.after / 1


  computeActionsToBecome: (after) ->
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
      continue if a == b
      if Math.abs(a-b) == 1
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
    @worldPos = @nextPos = point
    @dragging = false
    @alpha = 1
    window.Game.onActorDragged(@)


window.ProgrammableSprite = ProgrammableSprite
