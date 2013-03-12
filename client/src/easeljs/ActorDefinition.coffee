class ActorDefinition

  constructor: (json) ->
    @name = 'Untitled'
    @identifier = 'untitled'
    @img = null
    @size = {width: 1, height: 1}
    @spritesheet =
      data: undefined,
      animations: { idle: [0,0] }
    @rules = []

    @[key] = value for key, value of json
    @

  save: () =>
    json =
      identifier: @identifier
      name: @name
      spritesheet: @spritesheet
      rules: @rules

    window.Socket.emit 'put-actor', {identifier: @identifier, definition: json}

  updateImageData: (data) ->
    @spritesheet.data = data
    @img.src = data


window.ActorDefinition = ActorDefinition