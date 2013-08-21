@WorldsCtrl = ($scope, $dialog, $location, Users, Worlds, Comments, Auth, $http) ->

	$scope.worlds = []
	Worlds.mine {}, (worlds) ->
		$scope.worlds = worlds

	$scope.newWorld = () ->
		data = {title: 'Untitled World', description: 'A brand new world!'}
		Worlds.create data, (world) ->
			$location.path("/world/#{world._id}")


@WorldsCtrl.$inject = ['$scope', '$dialog', '$location', 'Users', 'Worlds', 'Comments', 'Auth', '$http']
