
class LibraryManager


  constructor: (name, progressCallback) ->
    @libraryName = name
    @libraryProgressCallback = progressCallback
    @definitions = {}
    @


  # -- Actor Definitions -- #

  loadActorDefinitions: (IDs, callback) =>
    return callback(null) unless IDs && IDs.length
    async.each(IDs, @loadActorDefinition, callback)


  loadActorDefinition: (ID, callback) =>
    return callback(null) if @definitions[ID]
    @outstanding += 1

    $.ajax({
      url: "/api/v0/worlds/#{window.Game.world_id}/actors/#{ID}"
    }).done (json) =>
      definition = new ActorDefinition(json)
      @addActorDefinition(definition, callback)


  createActorDefinition: (callback) =>
    $.ajax({
      url:  "/api/v0/worlds/#{window.Game.world_id}/actors"
      type: "POST"
    }).done (json) =>
      actor = new ActorDefinition(json)
      @addActorDefinition(actor, callback)


  addActorDefinition: (definition, callback = null) =>
    definition.img = new Image()
    definition.img.src = ""

    $(definition.img).on 'load', () =>
      $(definition.img).off('load')

      @outstanding -= 1
      @definitions[definition._id] = definition

      progress = (@definitions.length / (@definitions.length + @outstanding)) * 100
      @libraryProgressCallback({progress: progress})
      callback(definition) if callback

    definition.spritesheet.data ||= './img/splat.png'
    definition.img.src = definition.spritesheet.data
    definition

  # -- Using Actor Descriptors to Reference Actors ---#

  instantiateActorFromDescriptor: (descriptor, initial_position = null) ->
    definition = @definitions[descriptor.definition_id]
    return false unless definition

    pos = new Point(-1,-1)
    pos = Point.fromHash(descriptor.position) if descriptor.position
    pos = initial_position if initial_position

    model = new ActorSprite(definition._id, pos, definition.size)
    model.setSpriteSheet(definition.spritesheetInstance())
    model._id = descriptor._id || descriptor.actor_id_during_recording || Math.createUUID()
    model.definition = definition

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
