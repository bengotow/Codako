
class LibraryManager


  constructor: (libraryName) ->
    @libraryName = libraryName
    @definitions = {}
    window.Socket.on 'actorlist', (actors) =>
      @definitions[actor.identifier] = actor for actor in actors


  instantiateActorFromDescriptor: (descriptor, level) ->
    def = @definitions[descriptor.identifier]
    return false unless def

    model = new ProgrammableSprite(descriptor.position, def.size, level)
    model.createSpriteSheet(def.spritesheet.name, def.spritesheet.animations)
    model.rules = def.rules
    model


  actorMatchesDescriptor: (actor, descriptor) ->
    actor.identifier == descriptor.identifier


window.LibraryManager = LibraryManager
