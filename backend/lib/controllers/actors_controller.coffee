
# --------------------------------
# Operations on comment Collection
# --------------------------------

exports.actors_get = (req, res) ->
  req.withWorld (world) ->
    world.findActors (err, actors) ->
      res.endWithJSON(actors)


exports.actors_post = (req, res) ->
  req.withWorld (world) ->

    actor = new Actor()
    actor.world = world
    actor.save (err, actor) ->
      return res.endWithError(err, 400) if err
      res.endWithJSON(actor)


# --------------------------------
# Operations on comment Instances
# --------------------------------

exports.actor_get = (req, res) ->
  req.withWorld (world) ->
    Actor.findOne {world: world._id, definitionId: req.pathArgs[1] }, (err, actor) ->
      res.endWithJSON(actor)


exports.actor_put = (req, res) ->
  req.withWorld (world) ->
    Actor.findOne {world: world._id, definitionId: req.pathArgs[1] }, (err, actor) ->
      return res.endWithError('request.not_found', 404) unless actor
      return res.endWithUnauthorized() unless actor.isWithinWorld(world)

      for attribute in ['name', 'spritesheet', 'rules', 'variableDefaults']
        actor[attribute] = req.body[attribute] if req.body[attribute]

      actor.save (err, actor) ->
        return res.endWithError(err, 400) if err
        res.endWithJSON(actor)


exports.actor_delete = (req, res) ->
  req.withWorld (world) ->
    Actor.findOneAndRemove {world: world._id, definitionId: req.pathArgs[1], world: world._id}, (err) ->
      res.endWithJSON({success: true})

