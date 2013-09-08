@CommunityCtrl = ($scope, $dialog, Users, Worlds, Comments, Auth, $http) ->
	$scope.credentials = false
	$scope.worlds = []

	Worlds.popular {}, (worlds) ->
		$scope.worlds = worlds


@CommunityCtrl.$inject = ['$scope', '$dialog', 'Users', 'Worlds', 'Comments', 'Auth', '$http']
