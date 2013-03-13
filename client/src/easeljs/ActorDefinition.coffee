class ActorDefinition

  constructor: (json = {}) ->
    @name = 'Untitled'
    @identifier = 'untitled'
    @size = {width: 1, height: 1}
    @spritesheet =
      data: undefined,
      animations: { idle: [0,0] }
      animation_names: { idle: 'Idle' }
    @spritesheetObj = null
    @img = null

    @rules = []
    @ruleRenderCache = {}

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


  frameForAppearance: (identifier, index = 0) ->
    @spritesheet.animations[identifier][index]

  hasAppearance: (identifier) ->
    @spritesheet.animations[identifier] != null

  nameForAppearance: (identifier) ->
    @spritesheet.animation_names[identifier] || 'Untitled'

  renameAppearance: (identifier, newname) ->
    @spritesheet.animation_names[identifier] = newname

  addAppearance: (name = 'Untitled') ->
    identifier = 'a' + Math.floor((1 + Math.random()) * 0x10000).toString(6)
    animationCount = Object.keys(@spritesheet.animations).length
    framesWide = @img.width / (Tile.WIDTH * @size.width)
    index = framesWide * animationCount
    @spritesheet.animations[identifier] = [index]
    @spritesheet.animation_names[identifier] = name
    identifier

  deleteAppearance: (identifier) ->
    delete @spritesheet.animations[identifier]



window.ActorDefinition = ActorDefinition