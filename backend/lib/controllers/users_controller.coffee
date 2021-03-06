
# --------------------------------
# Operations on User Collection
# --------------------------------

# --------------------------------
# Operations on User Instances
# --------------------------------

exports.user_get = (req, res) ->
  User.findById req.pathArgs[0], (err, user) ->
    return res.endWithJSON(user) if user
    User.findOne {nickname: req.pathArgs[0]}, (err, user) ->
      res.endWithJSON(user)


exports.user_get_me = (req, res) ->
  console.log(req.user)
  return res.endWithError('users.not_found', 404) unless req.user
  res.endWithJSON(req.user)


exports.user_get_worlds = (req, res) ->
  User.findById req.pathArgs[0], (err, user) ->
    user.findWorlds (err, worlds) ->
      res.endWithJSON(worlds)


exports.user_put = (req, res) ->
  return res.endWithUnauthorized() unless req.user && req.user_is_self
  User.findByIdAndUpdate req.body._id, req.body, (err, user) ->
    res.endWithJSON(user)


exports.user_delete = (req, res) ->
  return res.endWithUnauthorized() unless req.user && req.user_is_self
  req.user.remove()
  res.endWithJSON({success: true})

exports.users_post = (req, res) ->
  user = new User(req.body)
  user.save (err, user) ->
    res.endWithJSON(user)
