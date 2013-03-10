
class LibraryManager


  constructor: (libraryName) ->
    @libraryName = libraryName
    @definitions = {}

    window.Socket.on 'actorlist', (actors) =>
      @definitions[actor.identifier] = actor for actor in actors


  instantiateActorFromDescriptor: (descriptor, level) ->
    ident = descriptor.identifier
    def = @definitions[ident]
    return false unless def

    pos = new Point(0,0)
    pos = Point.fromHash(descriptor.position) if descriptor.position

    model = new ProgrammableSprite(ident, pos, def.size, level)
    model.createSpriteSheet(def.spritesheet.name, def.spritesheet.animations)
    model.rules = def.rules
    model


  actorMatchesDescriptor: (actor, descriptor) ->
    actor.identifier == descriptor.identifier


window.LibraryManager = LibraryManager
