
# --------------------------------
# Operations on Stage Collection
# --------------------------------

exports.stages_post = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() unless req.user
    return res.endWithUnauthorized() unless world.isOwnedBy(req.user)
    req.body.world = world

    stage = new Stage(req.body)
    stage.save (stage) ->
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
    Stage.find({where: {id: req.pathArgs[1], world_id: world._id}}).success (stage)->
      res.endWithJSON(stage)


exports.stage_put = (req, res) ->
  req.withOwnedStage (stage) ->
    stage.updateAttributes(req.body).success (stage) ->
      res.endWithJSON(stage)

