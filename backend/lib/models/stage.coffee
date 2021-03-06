global.StageSchema = new mongoose.Schema
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  world: { type: mongoose.Schema.Types.ObjectId, ref: 'World' }

  width: { type: Number, default: 20 }
  height: { type: Number, default: 13 }
  wrapX: { type: Boolean, default: false }
  wrapY: { type: Boolean, default: false }

  thumbnail: { type:String, default: '/img/thumbnail_empty.png' }
  background: { type: String, default: null }
  tutorial_name: { type: String, default: null }
  tutorial_step: { type: Number, default: -1 }

  actor_library: {type: mongoose.Schema.Types.Mixed, default: []}
  actor_descriptors: {type: mongoose.Schema.Types.Mixed, default: []}

  start_descriptors: {type: mongoose.Schema.Types.Mixed, default: null}
  start_thumbnail: { type:String, default: '/img/thumbnail_empty.png' }

  resources: {type: mongoose.Schema.Types.Mixed, default: {
      images: {},
      sounds: {}
    }
  }

StageSchema.methods.isWithinWorld = (world) ->
  return false unless world
  @world && world._id.toString() == @world.toString()


module.exports = mongoose.model('Stage', StageSchema)
