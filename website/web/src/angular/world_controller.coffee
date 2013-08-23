@WorldCtrl = ($scope, $dialog, $location, $routeParams, Stages, Worlds, Comments, Auth, $http) ->

	$scope.world = {_id: $routeParams._id}

	Worlds.get $scope.world,
		(world) ->
			$scope.world = world

			Stages.index {world_id: $scope.world._id}, (stages) ->
					$scope.stages = stages

			Comments.index {world_id: $scope.world._id}, (comments) ->
					$scope.comments = comments
		,
		(error) ->
			$location.path('/home')


	$scope.newStage = () ->
		Stages.create {world_id: $scope.world._id}, (stage) ->
			$scope.openStage(stage)

	$scope.openStage = (stage) ->
		window.location.href = "/stage-editor/#/#{$scope.world._id}/#{stage._id}"


@WorldCtrl.$inject = ['$scope', '$dialog', '$location','$routeParams', 'Stages', 'Worlds', 'Comments', 'Auth', '$http']
