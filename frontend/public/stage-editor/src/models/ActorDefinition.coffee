class ActorDefinition

  constructor: (json = {}) ->
    @_id = null #always provided remotely

    @name = 'Untitled'
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

    # important. What we call the "_id" is actually "definitionId" in the
    # mongoDB database. This is because "_id" is globally unique in mongo,
    # and an actor with the same _id could exist in two different worlds
    # if the worlds were duplicated. Then they have differnet _ids on the server
    # but the definitionId value we use is still the same.
    @_id = @definitionId
    delete @definitionId

    @rules = Rule.inflateRules(json['rules'])
    @ruleRenderCache = {}
    @

  spritesheetInstance: ->
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
    return null unless appearance && width > 0 && height > 0

    key = "#{appearance}:#{width}:#{height}"
    return @spritesheetIconCache[key] if @spritesheetIconCache[key]

    window.withTempCanvas width, height, (canvas, context) =>
      spritesheet = @spritesheetInstance()
      frame = spritesheet.getFrame(spritesheet.getAnimation(appearance).frames[0])
      context.drawImage(frame.image, frame.rect.x, frame.rect.y, frame.rect.width, frame.rect.height, 0, 0, width, height)
      @spritesheetIconCache[key] = canvas.toDataURL()

    @spritesheetIconCache[key]


  rebuildSpritesheetInstance: ->
    old = @spritesheetInstance()
    @spritesheetObj = null
    @spritesheetIconCache = {}
    @spritesheetInstance()
    for key, value of @spritesheetObj
      old[key] = value
    @spritesheetObj = old


  save: =>
    @saveDeferred ?= _.debounce(@_save, 1000)
    @saveDeferred()

  _save: ->
    json =
      definitionId: @_id
      name: @name
      spritesheet: @spritesheet
      variableDefaults: @variableDefaults
      rules: Rule.deflateRules(@rules)

    $.ajax({
      url: "/api/v0/worlds/#{window.Game.world_id}/actors/#{@_id}",
      data: angular.toJson(json),
      contentType: 'application/json',
      type: 'POST'
    }).done ->
      console.log('Actor Saved')


  updateImageData: (args = {data:null, width: 0}) ->
    @spritesheet.data = args.data
    @spritesheet.width = args.width
    @img.src = args.data
    setTimeout =>
      @rebuildSpritesheetInstance()
      @ruleRenderCache = {}
      window.rootScope.$apply()

      # make the currently selected actor refresh it's display cache
      # to force it to update if it's using the current appearance
      window.Game.selectedActor?.setSelected(true)

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
    if !@spritesheet.animation_names[identifier]

      throw "Asked for an appearance which does not exist."
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
    return if @findRule(rule)

    idle_group = false
    for existing in @rules
      idle_group = existing if existing.type == 'group-event' && existing.event == 'idle'

    if idle_group
      idle_group.rules.splice(0,0,rule)
    else
      @rules.splice(0,0,rule)

    @save()


  findRule: (rule, foundCallback = null, searchRoot = @rules) ->
    for ii in [0..searchRoot.length-1] by 1
      if searchRoot[ii]._id == rule._id
        foundCallback(searchRoot, ii) if foundCallback
        return true
      if searchRoot[ii].rules
        found = @findRule(rule, foundCallback, searchRoot[ii].rules)
        return true if found
    return false


  clearCacheForRule: (rule) ->
    @ruleRenderCache["#{rule._id}-before"] = null
    @ruleRenderCache["#{rule._id}-after"] = null

  removeRule: (rule) ->
    @findRule rule, (collection, index) =>
      collection.splice(index, 1)
      @save()


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


  addFlowGroup: ->
    @addRule(new FlowGroupRule())
    @save()

  # Variable Management

  variables: ->
    @variableDefaults

  variableIDs: ->
    _.map @variableDefaults, (item) -> item._id

  addVariable: ->
    newID = Math.createUUID()
    @variableDefaults[newID] =
      _id: newID,
      name: 'Untited',
      value: 0

  removeVariable: (variable) ->
    delete @variableDefaults[variable._id]


window.ActorDefinition = ActorDefinition