
class LibraryManager


  constructor: (name, progressCallback) ->
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
    return callback(null) unless identifiers && identifiers.length
    async.each(identifiers, @loadActorDefinition, callback)


  loadActorDefinition: (identifier, callback) =>
    return callback(null) if @definitions[identifier]
    @outstanding += 1
    @definitionReadyCallbacks[identifier] = callback
    window.Socket.emit 'get-actor', {identifier: identifier}


  addActorDefinition: (actor, readyCallback = null) =>
    actor.img = new Image()
    actor.img.onload = () =>
      @outstanding -= 1
      @definitions[actor.identifier] = actor

      progress = (@definitions.length / Object.keys(@definitionReadyCallbacks).length) * 100

      @libraryProgressCallback({progress: progress})
      console.log 'got actor identifier', actor.identifier
      @definitionReadyCallbacks[actor.identifier](null) if @definitionReadyCallbacks[actor.identifier]
      readyCallback(null) if readyCallback


    actor.spritesheet.data ||= '/game/img/splat.png'
    actor.img.src = actor.spritesheet.data


  # -- Using Actor Descriptors to Reference Actors ---#

  instantiateActorFromDescriptor: (descriptor, initial_position = null) ->
    ident = descriptor.identifier
    def = @definitions[ident]
    return false unless def

    pos = new Point(-1,-1)
    pos = Point.fromHash(descriptor.position) if descriptor.position
    pos = initial_position if initial_position

    model = new ActorSprite(ident, pos, def.size)
    model.setSpriteSheet(def.spritesheetInstance())
    model._id = descriptor._id || descriptor.actor_id_during_recording || Math.createUUID()

    model.definition = def
    model.variableValues = _.clone(descriptor.variableValues)
    model.variableValues ||= {}
    model.setAppearance(descriptor.appearance)
    model




window.LibraryManager = LibraryManager
