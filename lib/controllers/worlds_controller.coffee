
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
    return res.endWithUnauthorized() unless req.user && world.isOwnedBy(req.user)

    for attribute in ['title', 'description', 'published']
      world[attribute] = req.body[attribute] if req.body[attribute] != undefined

    world.save (err, world) ->
      return res.endWithError(err, 400) if err
      res.endWithJSON(world)

