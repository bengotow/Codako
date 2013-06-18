global.fs = require("fs")
global.crypto = require("crypto")
global.coffeescript = require('connect-coffee-script')
global.pathUtils = require("path")
global.redis = require("redis")
global.knox = require("knox")
global.fs = require("fs")
global._ = require('underscore')

UserController = require("./lib/user_controller")


# Read our configuration file
try
  global.env = JSON.parse(fs.readFileSync("configs/environment.json"))
catch err
  console.log "no environment file could be found."
  process.exit()


# Start our server
server = require("./server").start()

# Start a server, optionally over SSH
if env.socket_io.secure
  credentials =
    key: fs.readFileSync(env.socket_io.ssh_key_file)
    cert: fs.readFileSync(env.socket_io.ssh_cert_file)
  app = require("https").createServer(credentials, null)
else
  app = require("http").createServer()


# Open a redis connection
global.rdb = redis.createClient(env.redis.port, env.redis.host)
global.rdb.on "error", (err) ->
  console.log("REDIS error: " + err.toString())

if env.redis.password
  dbAuth = () ->
    rdb.auth env.redis.password, () ->
     console.log("Redis auth successful.")

  rdb.addListener('connected', dbAuth)
  rdb.addListener('reconnected', dbAuth)
  dbAuth()


# Open an S3 connection
global.s3 = knox.createClient
  key: env.aws.accesskey
  secret: env.aws.secretkey
  bucket: env.aws.bucket


# Launch socket.io on the server
app.listen(env.socket_io.port)
io = require("socket.io").listen(app)

io.sockets.on "connection", (socket) ->

  socket.on 'get-actor', (args = {identifier: 'untitled'}) ->
    socket.user.getActor args.identifier, (err, data) ->
      socket.emit 'actor', data

  socket.on 'put-actor', (args = {identifier: 'untitled', definition: {}}) ->
    socket.user.saveActor(args.identifier, args.definition)


  socket.on 'get-level', (args = {identifier: 'untitled'}) ->
    console.log "Request for Level #{args.identifier}"
    socket.user.getLevel args.identifier, (err, data) ->
      socket.emit 'level', data

  socket.on 'put-level', (data) ->
    socket.user.saveLevel(data.identifier, data)


  socket.on 'auth', (args) ->
    socket.user = new UserController()
    socket.user.authenticate args.username, args.password, (err) ->
      socket.emit 'auth-state', {err: err}
      if !err
        socket.user.getAssets 'default', (err, data) ->
          socket.emit "assetlist", data



console.log "Web is on port " + env.socket_io.port
console.log "Socket.io is on port " + env.connect.port