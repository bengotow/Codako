global.WorldSchema = new mongoose.Schema
  title: { type:String, default: 'Untitled World' }
  description: {type:String, default: 'A brand new world!' }
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  thumbnail: { type:String, default: '/img/thumbnail_empty.png' }
  published: { type:Boolean, default: false }


WorldSchema.methods.findComments = (callback) ->
  Comment.find({world: @_id}, callback)

WorldSchema.methods.findStages = (callback) ->
  Stage.find({world: @_id}, callback)

WorldSchema.methods.findActors = (callback) ->
  Actor.find({world: @_id}, callback)

WorldSchema.methods.isOwnedBy = (user) ->
  user._id.toString() == @user.toString()


module.exports = mongoose.model('World', WorldSchema)
