
class LibraryManager


  constructor: (libraryName) ->
    @libraryName = libraryName
    @definitions = {}
    @definitionReadyCallbacks = {}

    window.Socket.on 'actor', (actor_json) =>
      actor = new ActorDefinition(actor_json)
      @addActorDefinition(actor)


  # -- Actor Definitions -- #

  loadActorDefinitions: (identifiers, callback) =>
    return unless identifiers && identifiers.length
    async.each(identifiers, @loadActorDefinition, callback)


  loadActorDefinition: (identifier, callback) =>
    return if @definitions[identifier]
    @outstanding += 1
    @definitionReadyCallbacks[identifier] = callback
    window.Socket.emit 'get-actor', {identifier: identifier}


  addActorDefinition: (actor) =>
    img = new Image()
    img.onload = () =>
      actor.img = img
      @outstanding -= 1
      @definitions[actor.identifier] = actor
      window.Game.Manager.libraryActorsLoaded()
      console.log('Added Actor Definition', actor)
      callback = @definitionReadyCallbacks[actor.identifier]
      callback(null) if callback

    actor.spritesheet.data ||= '/game/img/Tiles/BlockA0.png'
    img.src = actor.spritesheet.data


  # -- Using Actor Descriptors to Reference Actors ---#

  instantiateActorFromDescriptor: (descriptor, level = null) ->
    ident = descriptor.identifier
    def = @definitions[ident]
    return false unless def

    pos = new Point(0,0)
    pos = Point.fromHash(descriptor.position) if descriptor.position

    model = new ProgrammableSprite(ident, pos, def.size, level)
    model.setSpriteSheet(def.spritesheetInstance())
    model.definition = def
    model.setAppearance(descriptor.appearance) if descriptor.appearance
    model



window.LibraryManager = LibraryManager
