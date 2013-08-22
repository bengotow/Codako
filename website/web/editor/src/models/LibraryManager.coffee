
class LibraryManager


  constructor: (name, progressCallback) ->
    @libraryName = name
    @libraryProgressCallback = progressCallback
    @definitions = {}
    @


  # -- Actor Definitions -- #

  loadActorDefinitions: (identifiers, callback) =>
    return callback(null) unless identifiers && identifiers.length
    async.each(identifiers, @loadActorDefinition, callback)


  loadActorDefinition: (identifier, callback) =>
    return callback(null) if @definitions[identifier]
    @outstanding += 1

    $.ajax({
      url: "/api/v0/worlds/#{window.Game.world_id}/actors/#{identifier}"
    }).done (json) =>
      actor = new ActorDefinition(json)
      @addActorDefinition(actor, callback)


  createActorDefinition: (callback) =>
    $.ajax({
      url:  "/api/v0/worlds/#{window.Game.world_id}/actors"
      type: "POST"
    }).done (json) =>
      actor = new ActorDefinition(json)
      @addActorDefinition(actor, callback)


  addActorDefinition: (actor, callback = null) =>
    actor.img = new Image()
    actor.img.src = ""

    $(actor.img).on 'load', () =>
      $(actor.img).off('load')

      @outstanding -= 1
      @definitions[actor._id] = actor

      progress = (@definitions.length / (@definitions.length + @outstanding)) * 100
      @libraryProgressCallback({progress: progress})
      callback(actor) if callback

    actor.spritesheet.data ||= './img/splat.png'
    actor.img.src = actor.spritesheet.data
    actor

  # -- Using Actor Descriptors to Reference Actors ---#

  instantiateActorFromDescriptor: (descriptor, initial_position = null) ->
    def = @definitions[descriptor._id]
    return false unless def

    pos = new Point(-1,-1)
    pos = Point.fromHash(descriptor.position) if descriptor.position
    pos = initial_position if initial_position

    model = new ActorSprite(ident, pos, def.size)
    model.setSpriteSheet(def.spritesheetInstance())
    model._id = descriptor._id || descriptor.actor_id_during_recording || Math.createUUID()
    model.definition = def

    if descriptor.variableValues
      model.variableValues = _.clone(descriptor.variableValues)

    else if descriptor.variableConstraints
      model.variableValues = {}
      for variable, constraint of descriptor.variableConstraints
        model.variableValues[variable] = constraint.value/1 if constraint.comparator == '='
        model.variableValues[variable] = constraint.value/1-1 if constraint.comparator == '<'
        model.variableValues[variable] = constraint.value/1+1 if constraint.comparator == '>'

    else
      model.variableValues ||= {}
    model.setAppearance(descriptor.appearance)
    model




window.LibraryManager = LibraryManager
