
# --------------------------------
# Operations on Stream Collection
# --------------------------------

exports.worlds_post = (req, res) ->
  return res.endWithUnauthorized() unless req.user
  req.body.user = req.user
  world = new World(req.body)
  world.save (err, world) ->
    res.endWithJSON(world)


exports.worlds_import = (req, res) ->
  return res.endWithUnauthorized() unless req.user
  world = new World({user: req.user})
  world.initWithExportJSON req.body, (err, world) ->
    return res.endWithError(err, 400) if err
    res.endWithJSON(world)


exports.worlds_get_popular = (req, res) ->
  World.find {published: true}, (err, worlds) ->
    res.endWithJSON(worlds)


# --------------------------------
# Operations on Stream Instances
# --------------------------------

exports.world_get = (req, res) ->
  req.withWorld (world) ->
    console.log(world)
    res.endWithJSON(world)



exports.world_export = (req, res) ->
  req.withWorld (world) ->
    world.buildExportJSON (json) ->
      res.setHeader('Content-disposition', "attachment; filename=#{world.title}.json");
      res.endWithJSON(json)


exports.world_clone = (req, res) ->
  req.withWorld (world) ->
    world.buildExportJSON (json) ->
      w = new World({user: req.user})
      w.initWithExportJSON json, (err, w) ->
        res.endWithJSON({world_id: w._id, stage_id: w.stages[0]._id})


exports.world_put = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() unless req.user && world.isOwnedBy(req.user)

    for attribute in ['title', 'description', 'published']
      world[attribute] = req.body[attribute] if req.body[attribute] != undefined

    world.save (err, world) ->
      return res.endWithError(err, 400) if err
      res.endWithJSON(world)

exports.world_delete = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() unless req.user && world.isOwnedBy(req.user)
    world.destroy () ->
      res.endWithJSON({success: true})
