global.WorldSchema = new mongoose.Schema
  title: { type:String, default: 'Untitled World' }
  description: {type:String, default: 'A brand new world!' }
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  thumbnail: { type:String, default: '/img/thumbnail_empty.png' }
  published: { type:Boolean, default: false }
  locked: {type: Boolean, default: false }
  views: {type:Number, default: 0 }

WorldSchema.methods.findComments = (callback) ->
  Comment.find({world: @_id}, callback)

WorldSchema.methods.findStages = (callback) ->
  Stage.find({world: @_id}, callback)

WorldSchema.methods.findActors = (callback) ->
  Actor.find({world: @_id}, callback)

WorldSchema.methods.isOwnedBy = (user) ->
  return false unless user
  user._id.toString() == @user.toString()

WorldSchema.methods.incrementViews = () ->
  @views += 1
  @save()

WorldSchema.methods.initWithExportJSON = (json, callback) ->
  @title = json['title']
  @description = json['description']
  @thumbnail = json['thumbnail']
  @published = false
  @locked = false

  @stages = []
  @actors = []

  async.parallel [
    (callback) =>
      async.each json['stages']
        ,
        (stageJSON) =>
          newStage = new Stage(stageJSON)
          newStage.world = @
          @stages.push(newStage)
          newStage.save()
        ,
        callback()
    ,
    (callback) =>
      async.each json['actors']
        ,
        (actorJSON) =>
          newActor = new Actor(actorJSON)
          newActor.world = @
          @actors.push(newActor)
          newActor.save()
        ,
        callback()
    ,
    (callback) =>
      @save(callback)
  ],
  (err) =>
    console.log(err)
    callback(err, @)


WorldSchema.methods.buildExportJSON = (callback) ->
    json = JSON.parse(JSON.stringify(@))
    delete json['_id']
    delete json['user']

    json.stages = []
    json.actors = []

    async.parallel [
      (callback) =>
        @findStages (err, stages) ->
          for stage in stages
            stageJSON = JSON.parse(JSON.stringify(stage))
            delete stageJSON['_id']
            json.stages.push(stageJSON)
          callback()

      ,
      (callback) =>
        @findActors (err, actors) ->
          for actor in actors
            actorJSON = JSON.parse(JSON.stringify(actor))
            delete actorJSON['_id']
            json.actors.push(actorJSON)
          callback()
    ],
    (err) ->
      console.log(err)
      callback(json)

WorldSchema.methods.destroy = (callback) ->
  Stage.remove {world: @}, (err) =>
    Actor.remove {world: @}, (err) =>
      World.remove {_id: @_id}, (err) ->
        callback()


module.exports = mongoose.model('World', WorldSchema)
