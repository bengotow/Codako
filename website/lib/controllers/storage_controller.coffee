exports._send = (res, path) ->
  s3.get("/user/#{world.user_id}/worlds/#{world._id}/stages/#{stage._id}.json").on('response', (stream) ->
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
    Stage.find({where: {_id: req.pathArgs[1], world_id: world._id}}).success (stage)->
      exports._send(req, "/user/#{world.user_id}/worlds/#{world._id}/stages/#{stage._id}.json")


exports.stage_post_data = (req, res) ->
  req.withWorld (world) ->
    Stage.find({where: {_id: req.pathArgs[1], world_id: world._id}}).success (stage)->
      headers =
        'Content-Length': res.headers['content-length']
        'Content-Type': res.headers['content-type']

      s3.putStream req, "/user/#{world.user_id}/worlds/#{world._id}/stages/#{stage._id}.json", headers, (err, res) ->
        res.endWithJSON({success: true})


exports.actor_get_data = (req, res) ->
  req.withWorld (world) ->
    actor_id = req.pathArgs[1]
    exports._send(req, "/user/#{world.user_id}/worlds/#{world._id}/actors/#{actor_id}.json")


exports.actor_post_data = (req, res) ->
  req.withWorld (world) ->
    headers =
      'Content-Length': res.headers['content-length']
      'Content-Type': res.headers['content-type']

    actor_id = req.pathArgs[1]
    s3.putStream req, "/user/#{world.user_id}/worlds/#{world._id}/actors/#{actor_id}.json", headers, (err, res) ->
      res.endWithJSON({success: true})

