@WorldCtrl = ($scope, $dialog, $location, $routeParams, Stages, Worlds, Comments, Auth, $http) ->

	$scope.world = {_id: $routeParams._id}
	$scope.edit_details_callback = null
	$scope.edit_message = null

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


	$scope.new_stage = () ->
		Stages.create {world_id: $scope.world._id}, (stage) ->
			$scope.openStage(stage)

	$scope.open_stage = (stage) ->
		window.location.href = "/stage-editor/#/#{$scope.world._id}/#{stage._id}"

	$scope.edit_details = () ->
		$('#editDetailsModal').modal({show:true})

	$scope.edit_details_save = () ->
		if $scope.world.title == '' || $scope.world.title.toLowerCase().indexOf('untitled') != -1
			return alert('Please give your world a title!')

		$('#editDetailsModal').modal('hide')

		if $scope.edit_details_callback
			$scope.edit_details_callback()
			$scope.edit_details_callback = null
		else
			Worlds.update $scope.world, (world) ->
				$scope.world = world


	$scope.publish = (force = false) ->
		if $scope.world.title == "Untitled World" && !force
			$scope.edit_details_callback = $scope.publish
			$scope.edit_message = 'Before you publish your world, please name it!'
			$scope.edit_details()
		else
			$scope.world.published = !$scope.world.published
			Worlds.update $scope.world, (world) ->
				$scope.world = world
				if world.published
					$('#publishModal').modal({show:true})



	$scope.publish_action_text = () ->
		if $scope.world.published
			return 'Unpublish'
		else
			return 'Publish'


@WorldCtrl.$inject = ['$scope', '$dialog', '$location','$routeParams', 'Stages', 'Worlds', 'Comments', 'Auth', '$http']
