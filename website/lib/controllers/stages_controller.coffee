
# --------------------------------
# Operations on Stage Collection
# --------------------------------

exports.stages_post = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() unless req.user
    return res.endWithUnauthorized() unless world.user_id == req.user.id
    req.body.id = null
    req.body.world_id = world.id
    delete req.body['updated_at']
    delete req.body['created_at']

    Stage.create(req.body).success (stage) ->
      res.endWithJSON(stage)


exports.stages_get = (req, res) ->
  req.withWorld (world) ->
    world.getStages().success (stages) ->
      res.endWithJSON(stages)


# --------------------------------
# Operations on Stage Instances
# --------------------------------

exports.stage_get = (req, res) ->
  req.withWorld (world) ->
    Stage.find({where: {id: req.pathArgs[1]/1, world_id: world.id}}).success (stage)->
      res.endWithJSON(stage)


exports.stage_put = (req, res) ->
  req.withOwnedStage (stage) ->
    stage.updateAttributes(req.body).success (stage) ->
      res.endWithJSON(stage)

