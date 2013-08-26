
# --------------------------------
# Operations on User Collection
# --------------------------------

# --------------------------------
# Operations on User Instances
# --------------------------------

exports.user_get = (req, res) ->
  return res.endWithUnauthorized() unless req.user
  User.findById req.pathArgs[0], (err, user) ->
    res.endWithJSON(user)


exports.user_get_me = (req, res) ->
  console.log(req.user)
  return res.endWithError('users.not_found', 404) unless req.user
  res.endWithJSON(req.user)


exports.user_put = (req, res) ->
  return res.endWithUnauthorized() unless req.user && req.user_is_self
  User.findByIdAndUpdate req.body._id, req.body, (err, user) ->
    res.endWithJSON(user)


exports.user_delete = (req, res) ->
  return res.endWithUnauthorized() unless req.user && req.user_is_self
  req.user.remove()
  res.endWithJSON({success: true})
