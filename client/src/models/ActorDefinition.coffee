class ActorDefinition

  constructor: (json = {}) ->
    @name = 'Untitled'
    @identifier = Math.createUUID()
    @variableDefaults = {}
    @size = {width: 1, height: 1}
    @spritesheet =
      data: undefined,
      animations: { idle: [0,0] }
      animation_names: { idle: 'Idle' }
    @spritesheetObj = null
    @spritesheetIconCache = {}
    @img = null

    @[key] = value for key, value of json
    @spritesheet.width ||= Tile.WIDTH
    @spritesheet.animation_names ||= {}

    @rules = Rule.inflateRules(json['rules'])
    @ruleRenderCache = {}
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


  iconForAppearance: (appearance, width, height) ->
    key = "#{appearance}:#{width}:#{height}"
    return @spritesheetIconCache[key] if @spritesheetIconCache[key]

    window.withTempCanvas width, height, (canvas, context) =>
      spritesheet = @spritesheetInstance()
      frame = spritesheet.getFrame(spritesheet.getAnimation(appearance).frames[0])
      context.drawImage(frame.image, frame.rect.x, frame.rect.y, frame.rect.width, frame.rect.height, 0, 0, width, height)
      @spritesheetIconCache[key] = canvas.toDataURL()

    @spritesheetIconCache[key]


  rebuildSpritesheetInstance: () ->
    old = @spritesheetObj
    @spritesheetObj = null
    @spritesheetIconCache = {}
    @spritesheetInstance()
    for key, value of @spritesheetObj
      old[key] = value
    @spritesheetObj = old


  save: () =>
    json =
      identifier: @identifier
      name: @name
      spritesheet: @spritesheet
      variableDefaults: @variableDefaults
      rules: Rule.deflateRules(@rules)

    console.log 'Saving Actor ', json, JSON.stringify(json)
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
    console.log "Adding Rule #{rule._id}"
    idle_group = false
    for existing in @rules
      idle_group = existing if existing.type == 'group-event' && existing.event == 'idle'

    if idle_group
      idle_group.rules.splice(0,0,rule)
    else
      @rules.splice(0,0,rule)

    @save()

  removeRule: (rule, searchRoot = @rules) ->
    for ii in [0..searchRoot.length-1] by 1
      if searchRoot[ii]._id == rule._id
        searchRoot.splice(ii, 1)
        @save()
        return
      if searchRoot[ii].rules
        @removeRule(rule, searchRoot[ii].rules)


  addEventGroup: (config = {event:'key', code:'36'}) ->
    has_events = false
    for existing in @rules
      has_events = true if existing.type == 'group-event'

    # if no events have been added yet, move the
    # existing rules into an "idle" event group
    if !has_events
      idle_group = new EventGroupRule()
      idle_group.rules = idle_group.rules.concat(@rules)
      @rules = [idle_group]

    new_group = new EventGroupRule()
    new_group.event = config.event
    new_group.code = config.code
    @rules.splice(0, 0, new_group)
    @save()


  addFlowGroup: () ->
    @addRule(new FlowGroupRule())
    @save()

  # Variable Management

  variables: () ->
    @variableDefaults

  variableIDs: () ->
    _.map @variableDefaults, (item) -> item._id

  addVariable: () ->
    newID = Math.createUUID()
    @variableDefaults[newID] =
      _id: newID,
      name: 'Untited',
      value: 0

  removeVariable: (variable) ->
    delete @variableDefaults[variable._id]


window.ActorDefinition = ActorDefinition