class ActorDefinition

  constructor: (json = {}) ->
    @name = 'Untitled'
    @identifier = 'untitled'
    @size = {width: 1, height: 1}
    @spritesheet =
      data: undefined,
      animations: { idle: [0,0] }
    @spritesheetObj = null
    @img = null

    @rules = []
    @ruleRenderCache = {}

    @[key] = value for key, value of json
    @spritesheet.width ||= Tile.WIDTH
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
    @spritesheetObj = null
    setTimeout ()=>
      @ruleRenderCache = {}
      window.rootScope.$apply()
    ,250


  xywhForSpritesheetFrame: (frame) ->
    perLine = @spritesheet.width / (@size.width * Tile.WIDTH)
    x = frame % perLine
    y = Math.floor(frame / perLine)
    [x * Tile.WIDTH, y * Tile.HEIGHT, @size.width * Tile.WIDTH, @size.height * Tile.HEIGHT]


  frameForAppearance: (name, index = 0) ->
    @spritesheet.animations[name][index]

  hasAppearance: (name) ->
    @spritesheet.animations[name] != null

  addAppearance: (name = 'Untitled') ->
    rootNameIndex = 0
    rootName = name
    # find an untaken name
    while (@spritesheet.animations[name])
      rootNameIndex += 1
      name = "#{rootName} #{rootNameIndex}"

    animationCount = Object.keys(@spritesheet.animations)
    framesWide = @img.width / (Tile.WIDTH * @size.width)
    index = framesWide * animationCount

    @spritesheet.animations[name] = [index,index]
    name



window.ActorDefinition = ActorDefinition