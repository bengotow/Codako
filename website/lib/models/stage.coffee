global.StageSchema = new mongoose.Schema
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  world: { type: mongoose.Schema.Types.ObjectId, ref: 'World' }

  width: { type: Number, default: 20 }
  height: { type: Number, default: 13 }
  wrapX: { type: Boolean, default: false }
  wrapY: { type: Boolean, default: false }
  thumbnail: { type:String, default: '/img/thumbnail_empty.png' }
  background: { type: String, default: null }

  actor_library: {type: mongoose.Schema.Types.Mixed, default: []}
  actor_descriptors: {type: mongoose.Schema.Types.Mixed, default: []}

  resources: {type: mongoose.Schema.Types.Mixed, default: {
      images: {"Layer0_0": {src:"/editor/img/Backgrounds/Layer0_0.png"}},
      sounds: {}
    }
  }

StageSchema.methods.isWithinWorld = (world) ->
  @world && world._id.toString() == @world.toString()


module.exports = mongoose.model('Stage', StageSchema)
