global.fs = require("fs")
global.crypto = require("crypto")
global.coffeescript = require('connect-coffee-script')
global.pathUtils = require("path")
global.redis = require("redis")
global.knox = require("knox")
global.async = require("async")
global.email = require("emailjs")
global.URI = require('url')
global.mongoose = require('mongoose')
global.helpers = require('./helpers')
global._ = require('underscore')
en = require ('./lang/en')

# Start our server
server = require("./server").start()

# Open a database connection
mongoURL = process.env['MONGODB_URL'] || process.env['MONGOHQ_URL']
global.mongo = mongoose.connect mongoURL, {}, (err) ->
  console.log('Mongo Connected', err)

# Load models
global.User = require('./lib/models/user')
global.Stage = require('./lib/models/stage')
global.World = require('./lib/models/world')
global.Actor = require('./lib/models/actor')
global.Comment = require('./lib/models/comment')

# Create tables if necessary
User.findOne {'nickname': 'bengotow'}, (err, user) ->
  if !user
    passwordmd5 = crypto.createHash('md5').update('doggums').digest('hex')
    u = new User({nickname: 'bengotow', email:'bengotow@gmail.com', password: passwordmd5})
    u.save()

# Create the tutorial game stage
global.tutorialWorld = new World(JSON.parse(fs.readFileSync('./prebaked/tutorial_world.json')))
global.tutorialStage = new Stage(JSON.parse(fs.readFileSync('./prebaked/tutorial_stage.json')))
global.tutorialActors = JSON.parse(fs.readFileSync('./prebaked/tutorial_actors.json'))

World.remove {_id:tutorialWorld._id}, (err) ->
  Stage.remove {_id:tutorialStage._id}, (err) ->
    tutorialWorld.save (err) ->
      console.log(err) if err
      tutorialStage.save (err) ->
        console.log(err) if err
        console.log("Created tutorial: #{global.tutorialWorld._id}")

_.each global.tutorialActors, (json) ->
  jsonActor = new Actor(json)
  console.log("Creating actor:  #{jsonActor._id}")
  Actor.remove {_id: jsonActor._id}, (err) ->
    jsonActor.save (err) ->
      return console.log(err) if err
      console.log("Created actor:  #{jsonActor._id}")


# Open an S3 connection
global.s3 = knox.createClient
  key: process.env['AWS_ACCESSKEY']
  secret: process.env['AWS_SECRETKEY']
  bucket: process.env['AWS_BUCKET']



# Prepare some translations and string constants
global.T8N = (keypath, substitutions = []) ->
  category = keypath.substr(0, keypath.indexOf('.'))
  item = keypath.substr(keypath.indexOf('.') + 1)
  text = en[category][item]

  if text == undefined
    return keypath

  for value in substitutions
    text = text.replace('%', value)
  text


# Launch the web server
console.log "Web is on port " + process.env['PORT']