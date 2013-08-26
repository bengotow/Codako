@ProfileCtrl = ($scope, $dialog, $location, Users, Worlds, Comments, Auth, $http) ->

	$scope.worlds = []
	Worlds.mine {}, (worlds) ->
		$scope.worlds = worlds

  $scope.user = () ->
    Auth.user()

	$scope.new_world = () ->
		data = {}
		Worlds.create data, (world) ->
			$location.path("/world/#{world._id}")


@ProfileCtrl.$inject = ['$scope', '$dialog', '$location', 'Users', 'Worlds', 'Comments', 'Auth', '$http']
