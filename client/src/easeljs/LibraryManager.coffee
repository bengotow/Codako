
class LibraryManager


  constructor: (name, progressCallback) ->
    @stage = stage
    @renderingStage = renderingStage

    @libraryName = name
    @libraryProgressCallback = progressCallback
    @definitions = {}
    @definitionReadyCallbacks = {}

    window.Socket.on 'actor', (actor_json) =>
      actor = new ActorDefinition(actor_json)
      @addActorDefinition(actor)

    @


  # -- Actor Definitions -- #

  loadActorDefinitions: (identifiers, callback) =>
    return unless identifiers && identifiers.length
    async.each(identifiers, @loadActorDefinition, callback)


  loadActorDefinition: (identifier, callback) =>
    return callback(null) if @definitions[identifier]
    @outstanding += 1
    @definitionReadyCallbacks[identifier] = callback
    console.log(@definitionReadyCallbacks)
    window.Socket.emit 'get-actor', {identifier: identifier}


  addActorDefinition: (actor, readyCallback = null) =>
    actor.img = new Image()
    actor.img.onload = () =>
      @outstanding -= 1
      @definitions[actor.identifier] = actor

      progress = (@definitions.length / Object.keys(@definitionReadyCallbacks).length) * 100

      @libraryProgressCallback({progress: progress})
      @definitionReadyCallbacks[actor.identifier](null) if @definitionReadyCallbacks[actor.identifier]
      readyCallback(null) if readyCallback


    actor.spritesheet.data ||= '/game/img/splat.png'
    actor.img.src = actor.spritesheet.data


  # -- Using Actor Descriptors to Reference Actors ---#

  instantiateActorFromDescriptor: (descriptor, level = null) ->
    ident = descriptor.identifier
    def = @definitions[ident]
    return false unless def

    pos = new Point(0,0)
    pos = Point.fromHash(descriptor.position) if descriptor.position

    console.log ('Instantiating Actor')
    model = new ProgrammableSprite(ident, pos, def.size, level)
    model.setSpriteSheet(def.spritesheetInstance())
    model.definition = def
    model.setAppearance(descriptor.appearance) if descriptor.appearance
    model




window.LibraryManager = LibraryManager
