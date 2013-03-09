
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
url = require("url")
posts = {}

# --- Exported (Public) Methods ---//

module.exports = {}
module.exports.start = ->
	app = connect()
		.use(setupLocals)
		.use(connect.logger("dev"))
		.use(connect.bodyParser())
		.use(coffeescript(
			baseDir: webdir
			force: true
			src: webdir
		))
		.use(connect.static(webdir))
		.use(handleUnknownURL)
		.listen(env.connect.port)