fs = require("fs")
crypto = require("crypto")

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

# Launch socket.io on the server
app.listen(env.socket_io.port)
io = require("socket.io").listen(app)
io.sockets.on "connection", (socket) ->
  socket.emit "auth-state",
    authenticated: false

  socket.on "auth", (args) ->
    console.log "auth message received:"
    console.log args
    User.findOne
      where:
        username: args.username
        password: args.password
    , (err, user) ->
      console.log err
      console.log user
      if user
        socket.emit "auth-state",
          authenticated: true

      else
        socket.emit "auth-state",
          authenticated: false
          error: "User not found."



console.log "Web is on port " + env.socket_io.port
console.log "Socket.io is on port " + env.connect.port