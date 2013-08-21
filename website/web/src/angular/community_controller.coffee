@CommunityCtrl = ($scope, $dialog, Users, Worlds, Comments, Auth, $http) ->
	$scope.credentials = false
	$scope.worlds = []

	Worlds.index {}, (worlds) ->
		$scope.worlds = worlds


@CommunityCtrl.$inject = ['$scope', '$dialog', 'Users', 'Worlds', 'Comments', 'Auth', '$http']
