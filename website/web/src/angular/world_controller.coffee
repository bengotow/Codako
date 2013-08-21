@WorldCtrl = ($scope, $dialog, $location, $routeParams, Stages, Worlds, Comments, Auth, $http) ->

	$scope.world = {id: $routeParams.id}

	Worlds.get $scope.world,
		(world) ->
			$scope.world = world
		,
		(error) ->
			$location.path('/home')


	Comments.index {world_id: $scope.world.id},
		(comments) ->
			$scope.comments = comments


	$scope.newStage = () ->
		data = {world_id: $scope.world.id}
		Stages.create data, (stage) ->
			$scope.openStage(stage)

	$scope.openStage = (stage) ->
		window.location.href = "/editor/#/#{$scope.world.id}/#{stage.id}"


@WorldCtrl.$inject = ['$scope', '$dialog', '$location','$routeParams', 'Stages', 'Worlds', 'Comments', 'Auth', '$http']
