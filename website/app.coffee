global.fs = require("fs")
global.crypto = require("crypto")
global.coffeescript = require('connect-coffee-script')
global.pathUtils = require("path")
global.redis = require("redis")
global.knox = require("knox")
global.async = require("async")
global.email = require("emailjs")
global.URI = require('url')
global.helpers = require('./helpers')
global._ = require('underscore')
en = require ('./lang/en')

# Start our server
server = require("./server").start()

# Open a database connection
global.Sequelize = require("sequelize")
sequelizePath = URI.parse(process.env['SEQUELIZE_URL'])

[username,password] = sequelizePath.auth.split(':')
global.sequelize = new Sequelize(sequelizePath.pathname[1..-1], username, password, {
  host: sequelizePath.hostname
  port: sequelizePath.port
  dialect: sequelizePath.protocol[0..-2]
  define:
    charset: 'utf8',
    collate: 'utf8_general_ci',
    timestamps: true
    underscored: true
})

# Load models
global.User = require('./lib/models/user')
global.Stage = require('./lib/models/stage')
global.World = require('./lib/models/world')
global.Comment = require('./lib/models/Comment')

User.hasMany(World)
World.belongsTo(User)

World.hasMany(Stage)
Stage.belongsTo(World)

User.hasMany(Comment)
Comment.belongsTo(User)

World.hasMany(Comment)
Comment.belongsTo(World)


# Create tables if necessary
sequelize.sync().success () ->
  # Create admin account if necessary
  User.count().success (count) ->
    if count == 0
      passwordmd5 = crypto.createHash('md5').update('doggums').digest('hex')
      User.create({nickname: 'bengotow', email:'bengotow@gmail.com', password: passwordmd5})


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