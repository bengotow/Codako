global.StageSchema = new mongoose.Schema
  content: String
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  world: { type: mongoose.Schema.Types.ObjectId, ref: 'World' }

module.exports = mongoose.model('Stage', StageSchema)
