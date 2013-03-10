String::lastPathComponent = () ->
  slash = @.lastIndexOf("/")
  @[slash..-1]

String::withoutExtension = () ->
  ext = pathUtils.extname(@)
  @[0..-(1+ext.length)]


class UserContentListing
  assetsInDirectory: (directory, options = {}, items = {}) ->
    files = fs.readdirSync("#{global.process.env['OLDPWD']}/#{env.connect.web_path}#{directory}")
    for filename in files
      isDirectory = !pathUtils.extname(filename)
      relativePath = "#{directory}/#{filename}"
      relativePath = relativePath.withoutExtension() if options.removeExtensions

      if isDirectory
        @assetsInDirectory(relativePath, options, items)
      else
        items[filename.withoutExtension()] = {src: relativePath}

    items

  assets: () ->
    resources = {}
    resources['images'] = @assetsInDirectory "/game/img"
    resources['sounds'] = @assetsInDirectory "/game/sounds", {removeExtensions: true}
    resources

  actors: () ->
    [
      {
        identifier: 'rock',
        size: {width: 1, height: 1}
        spritesheet: {
          name: "BlockA0",
          animations: {
            idle: [0,0]
          }
        }
      },
      {
        identifier: 'dude',
        size: {width: 1, height: 1}
        spritesheet: {
          name: "Player",
          animations: {
            walk: [0, 9, "walk", 4]
            die: [10, 21, false, 4]
            jump: [22, 32, false]
            celebrate: [33, 43, false, 4]
            idle: [44, 44]
          }
        }
        rules: [
          {
            name: 'Move Left',
            triggers: [{
              type:"key",
              code:37
            }],
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

module.exports = UserContentListing