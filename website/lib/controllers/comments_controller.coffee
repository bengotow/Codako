
# --------------------------------
# Operations on comment Collection
# --------------------------------

exports.comments_get = (req, res) ->
  req.withWorld (world) ->
    world.findComments (comments) ->
      res.endWithJSON(comments)


exports.comments_post = (req, res) ->
  req.withWorld (world) ->
    req.body.world = req.world
    req.body.user = req.user

    Comment.create(req.body).success (comment) ->
      comment = JSON.parse(JSON.stringify(comment))
      comment['user'] = req.user
      res.endWithJSON(comment)


# --------------------------------
# Operations on comment Instances
# --------------------------------

exports.comment_put = (req, res) ->
  req.withWorld (world) ->
    world.getComments({where: {id: req.pathArgs[1]}}).success (comment) ->
      comment.updateAttributes(req.body).success (comment) ->
        res.endWithJSON(comment)


exports.comment_delete = (req, res) ->
  req.withWorld (world) ->
    world.getComment req.pathArgs[1], (comment) ->
      if comment.isOwnedBy(req.user)
        comment.destroy().success () ->
          res.endWithJSON({success: true})

