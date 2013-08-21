exports._send = (res, path) ->
  s3.get("/user/#{world.user_id}/worlds/#{world.id}/stages/#{stage.id}.json").on('response', (stream) ->
    if res.statusCode == 200
      stream.setEncoding('utf8')
      stream.on 'data', (chunk) ->
        res.write(chunk)
      stream.on 'end', () ->
        res.end()
    else
      res.endWithError('streams.not_member', 404)
  ).end()



exports.stage_get_data = (req, res) ->
  req.withWorld (world) ->
    Stage.find({where: {id: req.pathArgs[1]/1, world_id: world.id}}).success (stage)->
      exports._send(req, "/user/#{world.user_id}/worlds/#{world.id}/stages/#{stage.id}.json")


exports.stage_post_data = (req, res) ->
  req.withWorld (world) ->
    Stage.find({where: {id: req.pathArgs[1]/1, world_id: world.id}}).success (stage)->
      headers =
        'Content-Length': res.headers['content-length']
        'Content-Type': res.headers['content-type']

      s3.putStream req, "/user/#{world.user_id}/worlds/#{world.id}/stages/#{stage.id}.json", headers, (err, res) ->
        res.endWithJSON({success: true})


exports.actor_get_data = (req, res) ->
  req.withWorld (world) ->
    actor_id = req.pathArgs[1]/1
    exports._send(req, "/user/#{world.user_id}/worlds/#{world.id}/actors/#{actor_id}.json")


exports.actor_post_data = (req, res) ->
  req.withWorld (world) ->
    headers =
      'Content-Length': res.headers['content-length']
      'Content-Type': res.headers['content-type']

    actor_id = req.pathArgs[1]/1
    s3.putStream req, "/user/#{world.user_id}/worlds/#{world.id}/actors/#{actor_id}.json", headers, (err, res) ->
      res.endWithJSON({success: true})

