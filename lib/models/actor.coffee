global.ActorSchema = new mongoose.Schema
  definitionId: { type: String, default: null }
  world: { type: mongoose.Schema.Types.ObjectId, ref: 'World' }
  name: { type: String, default: 'Untitled' }
  spritesheet: { type: mongoose.Schema.Types.Mixed, default: {animations: {idle: [0,0]}, animation_names: { idle: 'Idle' }} }
  rules: { type: Array, default: [] }
  variableDefaults: { type: mongoose.Schema.Types.Mixed, default: {} }

ActorSchema.pre 'save', (next) ->
  @definitionId = Math.random().toString(36).substring(7) unless @definitionId
  next()

ActorSchema.methods.isWithinWorld = (world) ->
  return false unless world
  @world && world._id.toString() == @world.toString()

module.exports = mongoose.model('Actor', ActorSchema)
