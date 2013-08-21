
# --------------------------------
# Operations on User Collection
# --------------------------------

# --------------------------------
# Operations on User Instances
# --------------------------------

exports.user_get = (req, res) ->
  return res.endWithUnauthorized() unless req.user
  User.find(req.pathArgs[0]).success (user) ->
    res.endWithJSON(user)


exports.user_get_me = (req, res) ->
  return res.endWithError('users.not_found', 404) unless req.user
  res.endWithJSON(req.user)


exports.user_put = (req, res) ->
  return res.endWithUnauthorized() unless req.user && req.user_is_self
  req.user.updateAttributes(req.body).success (user) ->
    res.endWithJSON(user)


exports.user_delete = (req, res) ->
  return res.endWithUnauthorized() unless req.user && req.user_is_self
  req.user.destroy()
  res.endWithJSON({success: true})
