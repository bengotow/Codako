@CommunityCtrl = ($scope, $dialog, Users, Worlds, Comments, Auth, $http) ->
	$scope.worlds = []

	Worlds.popular {}, (worlds) ->
		$scope.worlds = worlds


@CommunityCtrl.$inject = ['$scope', '$dialog', 'Users', 'Worlds', 'Comments', 'Auth', '$http']
