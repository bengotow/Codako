
class LibraryManager


  constructor: (libraryName) ->
    @libraryName = libraryName
    @definitions = {}
    @definitionReadyCallbacks = {}

    window.Socket.on 'actor', (actor_json) =>
      img = new Image()
      actor = new ActorDefinition(actor_json)

      img.onload = () =>
        actor.img = img
        @outstanding -= 1
        @addActorDefinition(actor)
        callback = @definitionReadyCallbacks[actor.identifier]
        callback(null) if callback

      actor.spritesheet.data ||= '/game/img/Tiles/BlockA0.png'
      img.src = actor.spritesheet.data


  # -- Actor Definitions -- #

  loadActorDefinitions: (identifiers, callback) =>
    return unless identifiers && identifiers.length
    async.each(identifiers, @loadActorDefinition, callback)


  loadActorDefinition: (identifier, callback) =>
    return if @definitions[identifier]
    @outstanding += 1
    @definitionReadyCallbacks[identifier] = callback
    window.Socket.emit 'get-actor', {identifier: identifier}


  addActorDefinition: (def) =>
    @definitions[def.identifier] = def
    window.Game.Manager.libraryActorsLoaded()
    console.log('Added Actor Definition', def)


  # -- Using Actor Descriptors to Reference Actors ---#

  instantiateActorFromDescriptor: (descriptor, level = null) ->
    ident = descriptor.identifier
    def = @definitions[ident]
    return false unless def

    pos = new Point(0,0)
    pos = Point.fromHash(descriptor.position) if descriptor.position

    model = new ProgrammableSprite(ident, pos, def.size, level)
    model.createSpriteSheet(def.img, def.spritesheet.animations)
    model.definition = def
    console.log('Instantiated', model)
    model


  actorMatchesDescriptor: (actor, descriptor) ->
    actor.identifier == descriptor.identifier


window.LibraryManager = LibraryManager
