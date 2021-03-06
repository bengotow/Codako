
# --------------------------------
# Operations on Stage Collection
# --------------------------------

exports.stages_post = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() unless req.user
    return res.endWithUnauthorized() unless world.isOwnedBy(req.user)
    req.body.world = world

    stage = new Stage(req.body)
    stage.save (err, stage) ->
      console.log(stage, err)
      res.endWithJSON(stage)


exports.stages_get = (req, res) ->
  req.withWorld (world) ->
    world.findStages (err, stages) ->
      res.endWithJSON(stages)


# --------------------------------
# Operations on Stage Instances
# --------------------------------


exports.stage_get = (req, res) ->
  req.withWorld (world) ->
    Stage.findOne {_id: req.pathArgs[1], world: world._id}, (err, stage) ->
      res.endWithJSON(stage)


exports.stage_put = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() if world.user && !world.isOwnedBy(req.user)
    Stage.findById req.pathArgs[1], (err, stage) ->
      return res.endWithError('request.not_found', 404) unless stage
      return res.endWithUnauthorized() unless stage.isWithinWorld(world)

      for attribute in ['width', 'height', 'wrapX', 'wrapY', 'actor_library', 'tutorial_step', 'actor_descriptors', 'start_descriptors', 'start_thumbnail', 'resources', 'thumbnail', 'background']
        stage[attribute] = req.body[attribute] if req.body[attribute]

      if req.body.thumbnail
        world.thumbnail = req.body.thumbnail
        world.save()

      stage.save (err, stage) ->
        return res.endWithError(err, 400) if err
        res.endWithJSON(stage)


exports.stage_delete = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() if world.user && !world.isOwnedBy(req.user)
    Stage.findOneAndRemove {_id: req.body._id, world: world._id}, (err) ->
      res.endWithJSON({success: true})
