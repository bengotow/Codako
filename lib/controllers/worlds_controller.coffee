
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


exports.world_clone = (req, res) ->
  req.withWorld (world) ->
    json = JSON.parse(JSON.stringify(world))
    delete json['_id']
    delete json['user']
    newWorld = new World(json)
    newWorld.user = req.user
    newWorld.stages = []
    console.log(newWorld)
    async.parallel [
      (callback) ->
        world.findStages (err, stages) ->
          async.each stages,
            (stage) ->
              json = JSON.parse(JSON.stringify(stage))
              delete json['_id']
              newStage = new Stage(json)
              newStage.world = newWorld
              newWorld.stages.push(newStage)
              newStage.save()
            ,
            callback()

      ,
      (callback) ->
        world.findActors (err, actors) ->
          async.each actors,
            (actor) ->
              json = JSON.parse(JSON.stringify(actor))
              delete json['_id']
              newActor = new Actor(json)
              newActor.world = newWorld
              newActor.save()
            ,
            callback()
      ,
      (callback) ->
        newWorld.save(callback)
    ],
    (err) ->
      console.log(err)
      res.endWithJSON({world_id: newWorld._id, stage_id: newWorld.stages[0]._id})



exports.world_put = (req, res) ->
  req.withWorld (world) ->
    return res.endWithUnauthorized() unless req.user && world.isOwnedBy(req.user)

    for attribute in ['title', 'description', 'published']
      world[attribute] = req.body[attribute] if req.body[attribute] != undefined

    world.save (err, world) ->
      return res.endWithError(err, 400) if err
      res.endWithJSON(world)

