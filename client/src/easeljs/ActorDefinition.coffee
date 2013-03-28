class ActorDefinition

  constructor: (json = {}) ->
    @name = 'Untitled'
    @identifier = Math.createUUID()
    @size = {width: 1, height: 1}
    @spritesheet =
      data: undefined,
      animations: { idle: [0,0] }
      animation_names: { idle: 'Idle' }
    @spritesheetObj = null
    @img = null

    @rules = []
    @ruleRenderCache = {}

    @variableDefaults = {}

    @[key] = value for key, value of json
    @spritesheet.width ||= Tile.WIDTH
    @spritesheet.animation_names ||= {}

    @

  spritesheetInstance: () ->
    return @spritesheetObj if @spritesheetObj
    @spritesheetObj = new SpriteSheet(
      images: [@img]
      animations: @spritesheet.animations
      frames:
        width: Tile.WIDTH * @size.width
        height: Tile.HEIGHT * @size.height
        regX: 0
        regY: 0
    )
    SpriteSheetUtils.addFlippedFrames(@spritesheetObj, true, false, false)
    @spritesheetObj


  rebuildSpritesheetInstance: () ->
    old = @spritesheetObj
    @spritesheetObj = null
    @spritesheetInstance()
    for key, value of @spritesheetObj
      old[key] = value
    @spritesheetObj = old


  save: () =>
    json =
      identifier: @identifier
      name: @name
      spritesheet: @spritesheet
      variables: @variableDefaults
      rules: @rules

    console.log 'Saving Actor ', json
    window.Socket.emit 'put-actor', {identifier: @identifier, definition: json}


  updateImageData: (args = {data:null, width: 0}) ->
    @spritesheet.data = args.data
    @spritesheet.width = args.width
    @img.src = args.data
    setTimeout () =>
      @rebuildSpritesheetInstance()
      @ruleRenderCache = {}
      window.rootScope.$apply()
    ,250


  xywhForSpritesheetFrame: (frame) ->
    perLine = @spritesheet.width / (@size.width * Tile.WIDTH)
    x = frame % perLine
    y = Math.floor(frame / perLine)
    [x * Tile.WIDTH, y * Tile.HEIGHT, @size.width * Tile.WIDTH, @size.height * Tile.HEIGHT]


  # Appearance Management

  frameForAppearance: (identifier, index = 0) ->
    @spritesheet.animations[identifier][index]

  hasAppearance: (identifier) ->
    @spritesheet.animations[identifier] != null

  nameForAppearance: (identifier) ->
    @spritesheet.animation_names[identifier] || 'Untitled'

  renameAppearance: (identifier, newname) ->
    @spritesheet.animation_names[identifier] = newname

  addAppearance: (name = 'Untitled') ->
    identifier = Math.createUUID()
    animationCount = Object.keys(@spritesheet.animations).length
    framesWide = @img.width / (Tile.WIDTH * @size.width)
    index = framesWide * animationCount
    @spritesheet.animations[identifier] = [index]
    @spritesheet.animation_names[identifier] = name
    identifier


  deleteAppearance: (identifier) ->
    delete @spritesheet.animations[identifier]


  # Rule Management

  addRule: (rule) ->
    idle_group = false
    for existing in @rules
      idle_group = existing if existing.type == 'group-event' && existing.event == 'idle'

    if idle_group
      idle_group.rules.splice(0,0,rule)
    else
      @rules.splice(0,0,rule)

    @save()

  removeRule: (rule, searchRoot = @rules) ->
    for ii in [0..searchRoot.length-1]
      if searchRoot[ii]._id == rule._id
        searchRoot.splice(ii, 1)
        @save()
        return
      if searchRoot[ii].rules
        @removeRule(rule, searchRoot[ii].rules)


  addEventGroup: (rule = {event:'key', code:'36'}) ->
    has_events = false
    for existing in @rules
      has_events = true if existing.type == 'group-event'

    # if no events have been added yet, move the
    # existing rules into an "idle" event group
    if !has_events
      idle =
        _id: Math.createUUID()
        type: 'group-event'
        event: 'idle'
        rules: [].concat(@rules)
      @rules = [idle]

    rule._id = Math.createUUID()
    rule.type = 'group-event'
    rule.rules = []

    @rules.splice(0, 0, rule)
    @save()


  addFlowGroup: () ->
    @addRule
      _id: Math.createUUID()
      type: 'group-flow',
      name: 'Untitled Group',
      behavior: 'all',
      rules: []


  # Variable Management

  variables: () ->
    @variableDefaults

  addVariable: () ->
    newID = Math.createUUID()
    @variableDefaults[newID] =
      _id: newID,
      name: 'Untited',
      value: 0

  removeVariable: (variable) ->


window.ActorDefinition = ActorDefinition