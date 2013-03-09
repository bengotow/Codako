String::lastPathComponent = () ->
	slash = @.lastIndexOf("/")
	@[slash..-1]

String::withoutExtension = () ->
	ext = pathUtils.extname(@)
	@[0..-(1+ext.length)]


class AssetListing
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
		resources['images'] = @assetsInDirectory "/img"
		resources['sounds'] = @assetsInDirectory "/sounds", {removeExtensions: true}
		resources


module.exports = AssetListing