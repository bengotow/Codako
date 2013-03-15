String::lastPathComponent = () ->
  slash = @.lastIndexOf("/")
  @[slash..-1]

String::withoutExtension = () ->
  ext = pathUtils.extname(@)
  @[0..-(1+ext.length)]


class UserController

  @DEFAULT_LEVEL =
    {
      identifier: 'untitled'
      width: 20
      height: 13
      actor_library: ['rock', 'dude']
      actor_descriptors: [
        {
          identifier: 'dude',
          position: {x: 10, y: 10}
        },
        {
          identifier: 'rock',
          position: {x: 7, y: 10}
        }
      ]
    }

  @DEFAULT_ACTORS = {
    'rock':
      {
        name:'Rock'
        identifier: 'rock',
        size: {width: 1, height: 1}
        spritesheet: {
          width: 40
          animations: {
            idle: [0,0]
          }
        }
      }
    'dude':
      {
        name: 'Dude'
        identifier: 'dude',
        size: {width: 1, height: 1}
        spritesheet: {
          width: 40
          animations: {
            idle: [0,0]
            walk: [1,1]
          }
        }
        rules: [
          {
            _id: '111'
            type: 'group-event'
            event:"key",
            code:37,
            rules: [
              {
                _id: '222'
                type: 'group-flow',
                behavior: 'all',
                rules: [
                  {
                    _id: '001'
                    name: 'Move Left',
                    scenario: [{
                      coord:"-1,0",
                      descriptors: false
                    },{
                      coord:"0,0",
                      descriptors: [{
                        identifier: 'dude'
                        actions: [{
                          type:"move",
                          delta:"-1,0"
                        }]
                      }]
                    }]
                  }
                ]
              }
            ]
          }
          ,
          {
            _id: '333'
            type: 'group-event'
            event:"key",
            code:39,
            rules: [
              {
                _id: '666'
                name: 'Move Right',
                scenario: [{
                  coord:"1,0",
                  descriptors: false
                },{
                  coord:"0,0",
                  descriptors: [{
                    identifier: 'dude'
                    actions: [{
                      type:"move",
                      delta:"1,0"
                    }]
                  }]
                }]
              }
            ]
          },
          {
            _id: '444'
            type: 'group-event'
            event: 'idle',
            rules: [
              {
                _id: '555'
                type: 'group-flow',
                behavior: 'random',
                rules: [
                  {
                    _id: '777'
                    name: 'Move Up',
                    scenario: [{
                      coord:"0,-1",
                      descriptors: false
                    },{
                      coord:"0,0",
                      descriptors: [{
                        identifier: 'dude'
                        actions: [{
                          type:"move",
                          delta:"0,-1"
                        }]
                      }]
                    }]
                  },
                  {
                    _id: '999'
                    name: 'Move Down',
                    scenario: [{
                      coord:"0,1",
                      descriptors: false
                    },{
                      coord:"0,0",
                      descriptors: [{
                        identifier: 'dude'
                        actions: [{
                          type:"move",
                          delta:"0,1"
                        }]
                      }]
                    }]
                  }
                ]
              }
            ]
          }
        ]
      }
    }


  constructor: () ->
    @username = null
    @password = null

  authenticate: (username, password, callback) ->
    @username = username
    @password = password
    callback(null)

  assetsInDirectory: (directory, options = {}, items = {}) ->
    files = fs.readdirSync("#{env.connect.web_path}#{directory}")
    for filename in files
      isDirectory = !pathUtils.extname(filename)
      relativePath = "#{directory}/#{filename}"
      relativePath = relativePath.withoutExtension() if options.removeExtensions

      if isDirectory
        @assetsInDirectory(relativePath, options, items)
      else
        items[filename.withoutExtension()] = {src: relativePath}

    items

  getAssets: (identifier, callback) ->
    return callback(new Error('Permission Denied')) if !@username
    resources = {}
    resources['images'] = @assetsInDirectory "/game/img"
    resources['sounds'] = @assetsInDirectory "/game/sounds", {removeExtensions: true}
    callback(null, resources)


  getLevel: (identifier, callback) ->
    return callback(new Error('Permission Denied')) if !@username
    rdb.get "u:#{@username}-l:#{identifier}", (err, result) =>
      result = JSON.parse(result) if result
      if result == null
        result = JSON.parse(JSON.stringify(UserController.DEFAULT_LEVEL))
        result.identifier = identifier
      callback(err, result)


  saveLevel: (identifier, data, callback) ->
    return callback(new Error('Permission Denied')) if !@username
    try
      data = JSON.stringify(data) unless data instanceof String
    catch e
      callback(new Error('Invalid JSON'))

    rdb.set "u:#{@username}-l:#{identifier}", data, callback


  getActor: (identifier, callback) ->
    return callback(new Error('Permission Denied')) if !@username
    rdb.get "u:#{@username}-a:#{identifier}", (err, result) =>
      result = JSON.parse(result) if result
      result = UserController.DEFAULT_ACTORS[identifier] if result == null
      callback(err, result)


  saveActor: (identifier, data, callback) ->
    return callback(new Error('Permission Denied')) if !@username
    try
      data = JSON.stringify(data) unless data instanceof String
    catch e
      callback(new Error('Invalid JSON'))

    rdb.set "u:#{@username}-a:#{identifier}", data, callback


module.exports = UserController