
webdir = "#{__dirname}/#{env.connect.web_path}"

# --- Private Methods ---//
setupLocals = (req, res, next) ->
	req.locals = {}
	res.locals = {}
	next()

handleUnknownURL = (req, res, next) ->
	console.log "unknown url:", req.method, req.url
	next()

connect = require("connect")
less = require('connect-less')
url = require("url")
posts = {}

# --- Exported (Public) Methods ---//

module.exports = {}
module.exports.start = ->
	app = connect()
		.use(setupLocals)
		.use(connect.logger("dev"))
		.use(connect.bodyParser())
		.use(less(
			src: webdir
			debug: true
			force: true
		))
		.use(coffeescript(
			src: webdir
			baseDir: webdir
			force: true
		))
		.use(connect.static(webdir))
		.use(handleUnknownURL)
		.listen(env.connect.port)