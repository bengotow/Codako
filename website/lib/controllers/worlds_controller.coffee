
# --------------------------------
# Operations on Stream Collection
# --------------------------------

exports.worlds_post = (req, res) ->
  return res.endWithUnauthorized() unless req.user
  req.body.id = null
  req.body.user_id = req.user.id
  delete req.body['updated_at']
  delete req.body['created_at']

  World.create(req.body).success (world) ->
    res.endWithJSON(world)


exports.worlds_get_mine = (req, res) ->
  return res.endWithUnauthorized() unless req.user
  req.user.getWorlds().success (worlds) ->
    res.endWithJSON(worlds)


# --------------------------------
# Operations on Stream Instances
# --------------------------------

exports.world_get = (req, res) ->
  req.withWorld (world) ->
    res.endWithJSON(world)


exports.world_put = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() unless req.user && req.user.id == world.user_id
    world.updateAttributes(req.body).success (world) ->
      res.endWithJSON(world)

