
# --------------------------------
# Operations on Stream Collection
# --------------------------------

exports.worlds_post = (req, res) ->
  return res.endWithUnauthorized() unless req.user
  req.body.user = req.user
  world = new World(req.body)
  world.save (err, world) ->
    res.endWithJSON(world)


exports.worlds_get_mine = (req, res) ->
  return res.endWithUnauthorized() unless req.user
  req.user.findWorlds (err, worlds) ->
    res.endWithJSON(worlds)


# --------------------------------
# Operations on Stream Instances
# --------------------------------

exports.world_get = (req, res) ->
  req.withWorld (world) ->
    console.log(world)
    res.endWithJSON(world)


exports.world_put = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() unless req.user && req.user._id == world.user_id
    world.updateAttributes(req.body).success (world) ->
      res.endWithJSON(world)

