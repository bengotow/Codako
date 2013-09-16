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
			$scope.open_stage(stage)

	$scope.open_stage = (stage) ->
		if Auth.user()._id == world.user
			window.location.href = "/stage-editor/#/#{$scope.world._id}/#{stage._id}"
		else
			window.location.href = "/stage-viewer/#/#{$scope.world._id}/#{stage._id}"

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


	$scope.share = () ->
		$('#publishModal').modal({show:true})


	$scope.share_url = () ->
		if $scope.world && $scope.stages
			"http://#{window.location.host}/stage-viewer/#/#{$scope.world._id}/#{$scope.stages[0]._id}"
		else
			""

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
					$scope.share()




@WorldCtrl.$inject = ['$scope', '$dialog', '$location','$routeParams', 'Stages', 'Worlds', 'Comments', 'Auth', '$http']
