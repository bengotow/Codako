
# --------------------------------
# Operations on Stream Collection
# --------------------------------

exports.stages_post = (req, res) ->
  req.withOwnedStream (stream) ->
    req.body.stream_id = stream.id
    req.body.user_id = req.user.id
    req.body.points_max = null if req.body.points_max == ''
    delete req.body['updated_at']

    post = Post.build(req.body)
    post.validate().success (errors) ->
      return res.endWithJSON(errors, 400) if errors
      post.save().success (post) ->
        res.endWithJSON(post)

      if req.body.deliver_push
        stream.pushTokensForUsersSeeingPost post, (tokens) ->
          helpers.deliverPushNotification(tokens, "\u2709 #{req.user.first_name} posted a new update on #{stream.name}'s Highline!", stream)


exports.stages_get = (req, res) ->
  Stream.findAll().success (streams) ->
    res.endWithJSON(streams)


exports.user_stages_get = (req, res) ->
  return res.endWithUnauthorized() unless req.user
    req.user.getStages().success (stages) ->
      res.endWithJSON(stages)

# --------------------------------
# Operations on Stream Instances
# --------------------------------

exports.stream_get = (req, res) ->
  req.withStream (stream) ->
    res.endWithJSON(stream)


# --------------------------------
# Operations on Stream Instances
# --------------------------------

exports.stage_get = (req, res) ->
  req.withStage (stage) ->
    res.endWithJSON(stage)


exports.stage_put = (req, res) ->
  req.withStage (stage) ->
    return res.endWithUnauthorized() unless req.user && stage.user_id == req.user.id
    stage.updateAttributes(req.body).success (stage) ->
      res.endWithJSON(stage)


exports.stage_delete = (req, res) ->
  req.withStage (stage) ->
    return res.endWithUnauthorized() unless req.user && stage.user_id == req.user.id
    stage.destroy()
    res.endWithJSON({success: true})

