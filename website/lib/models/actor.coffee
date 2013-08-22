global.ActorSchema = new mongoose.Schema
  world: { type: mongoose.Schema.Types.ObjectId, ref: 'World' }
  name: { type: String, default: 'Untitled' }
  spritesheet: { type: mongoose.Schema.Types.Mixed, default: {animations: {idle: [0,0]}, animation_names: 'idle'} }
  rules: { type: Array, default: [] }
  variableDefaults: { type: mongoose.Schema.Types.Mixed, default: {} }


ActorSchema.methods.isWithinWorld = (world) ->
  @world && world._id.toString() == @world.toString()

module.exports = mongoose.model('Actor', ActorSchema)
