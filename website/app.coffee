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
global.mongo = mongoose.connect process.env['MONGODB_URL'], {}, (err) ->
  console.log('Mongo Connected', err)

# Load models
global.User = require('./lib/models/user')
global.Stage = require('./lib/models/stage')
global.World = require('./lib/models/world')
global.Actor = require('./lib/models/Actor')
global.Comment = require('./lib/models/Comment')

# Create tables if necessary
User.findOne {'nickname': 'bengotow'}, (err, user) ->
  if !user
    passwordmd5 = crypto.createHash('md5').update('doggums').digest('hex')
    u = new User({nickname: 'bengotow', email:'bengotow@gmail.com', password: passwordmd5})
    u.save()


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