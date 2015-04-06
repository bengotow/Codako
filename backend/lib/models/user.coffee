global.UserSchema = new mongoose.Schema
  email: String
  nickname: String
  password: String
  type: String
  createdAt: Date

UserSchema.methods.findWorlds = (callback) ->
  World.find({user: @_id}, callback)

module.exports = mongoose.model('User', UserSchema)
