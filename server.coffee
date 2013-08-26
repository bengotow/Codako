connect = require("connect")
less = require('connect-less')
url = require("url")

webdir = "#{__dirname}/#{process.env['WEB_BASE']}"
usersController = require('./lib/controllers/users_controller')
stagesController = require('./lib/controllers/stages_controller')
worldsController = require('./lib/controllers/worlds_controller')
actorsController = require('./lib/controllers/actors_controller')
commentsController = require('./lib/controllers/comments_controller')
global.T8NError = require ("./lib/models/t8n_error")

global.K_ERROR = "error"
global.K_ERROR_TYPE = "error_type"
global.K_RESULT = "result"

handlers =
	'/':
		'users':
			'/':
				'me':
					'GET':    usersController.user_get_me
				'%':
					'GET':    usersController.user_get
					'PUT':    usersController.user_put

		'worlds':
			'POST': worldsController.worlds_post
			'/':
				'mine':
					'GET':	worldsController.worlds_get_mine
				'popular':
					'GET':	worldsController.worlds_get_popular
				'%':
					'GET':		worldsController.world_get
					'PUT':		worldsController.world_put
					'DELETE':	worldsController.world_delete
					'/':
						'stages':
							'GET':  stagesController.stages_get
							'POST': stagesController.stages_post
							'/':
								'%':
									'GET': stagesController.stage_get
									'PUT': stagesController.stage_put
									'POST': stagesController.stage_put

						'actors':
							'GET':  actorsController.actors_get
							'POST': actorsController.actors_post
							'/':
								'%':
									'GET': actorsController.actor_get
									'PUT': actorsController.actor_put
									'POST': actorsController.actor_put

						'comments':
							'GET':	commentsController.comments_get
							'POST':	commentsController.comments_post
							'/':
								'%':
									'GET':    commentsController.comment_get
									'PUT':    commentsController.comment_put
									'DELETE': commentsController.comment_delete



# --- Private Methods ---//
setupLocals = (req, res, next) ->
	req.locals = {}
	req.withWorld = (callback) ->
		World.findById req.pathArgs[0], (err, world) ->
			return res.endWithError('streams.not_member', 404) unless world
			callback(world)


	res.locals = {}
	res.endWithJSON = (json, response_code = 200) ->
		res.writeHead(response_code, { 'Content-Type': 'application/json'})
		res.end(JSON.stringify(json))

	res.endWithUnauthorized = () ->
		res.writeHead(401, { 'Content-Type': 'application/json', 'WWW-Authenticate': 'Basic realm="API"'})
		res.end(JSON.stringify({'error': 'unauthorized'}))

	res.endWithError = (err, response_code = 200) ->
		err = 'undefined' if !err?

		if err instanceof T8NError
			@e = err.toString()
			@et = err.error_type
		else if typeof err == "string"
			@e = T8N(err)
			@et = err
		else
			@e = err.toString()
			@e = @e.substr(@e.indexOf("Error: ") + 7) if @e.indexOf("Error: ") != -1
			@et = 'unknown'

			if @e.indexOf('ECONNREFUSED') != -1
				@e = 'mySQL connection refused.'

		obj = {}
		obj[K_RESULT] = false
		obj[K_ERROR] = @e
		obj[K_ERROR_TYPE] = @et
		console.log(@e)

		res.writeHead(response_code, { 'Content-Type': 'application/json'})
		res.end(JSON.stringify(obj))

	next()


handleUnknownURL = (req, res, next) ->
	console.log "unknown url:", req.method, req.url
	next()


handleAPIRequest = (req, res, next) ->
	return next() unless req.url[0..6] == '/api/v0'

	# route the request to the appropriate API controller
	path = req.url
	path = path[0..req.url.indexOf('?')-1] if req.url.indexOf('?') != -1
	components = path.split('/')[3..-1]

	# okay... let's traverse through our handle structure.
	method = req.method.toUpperCase()
	choices = handlers
	args = []

	for component in components
		choices = choices['/']
		unless (typeof choices == 'object')
			console.log("#{method} #{path} route: 404 Not Found")
			return res.endWithError('request.not_found_api', 404)

		if choices[component]
			choices = choices[component]
		else if choices['%']
			args.push(component)
			choices = choices['%']
		else
			console.log("#{method} #{path} route: 404 Not Found")
			return res.endWithError('request.not_found_api', 404)


	unless (typeof choices[method] == 'function')
		console.log("#{method} #{path} route: 405 Wrong Method")
		return res.endWithError('request.not_found_api_request_method', 405)

	# log the api request
	req.pathArgs = args
	console.log("#{method} #{path}", req.body)

	if req.headers.authorization
		parts = req.headers.authorization.split(' ')
		return res.endWithUnauthorized() unless parts.length == 2
		return res.endWithUnauthorized() unless parts[0] == 'Basic'

		credentials = new Buffer(parts[1], 'base64').toString().split(':')

		User.findOne {nickname: credentials[0], password: credentials[1]}, (err, user) ->
			if user
				req.user_is_self = (req.pathArgs[0] == user._id)
				req.user = user
				console.log('Request for user ' + user.nickname)
			choices[method](req, res)

	else
		choices[method](req, res)


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
		.use(connect.query())
		.use(handleAPIRequest)
		.use(handleUnknownURL)


	# Start a server, optionally over SSH
	if process.env['WEB_SSH_KEY']
	  credentials =
	    key: fs.readFileSync(process.env['WEB_SSH_KEY'])
	    cert: fs.readFileSync(process.env['WEB_SSH_CERT'])
	  require("https").createServer(credentials, app).listen(process.env['PORT'])
	else
	  require("http").createServer(app).listen(process.env['PORT'])
