
@MetadataCtrl = ($scope, $location, Users, Worlds, Stages, Auth, $http) ->

  Worlds.get { _id: window.world_id }, (world) ->
    $scope.world = world
    Users.get {_id: $scope.world.user }, (user) ->
      $scope.author = user

  $scope.cloneWorld = ->
    req = $http({method: 'POST', url:"/api/v0/worlds/#{$scope.world._id}/clone"})
    req.success (data, status, headers, config) ->
      if status != 200
        return alert('Sorry, the world doesn\'t seem to exist.')
      window.location.href = "/stage-editor/#/#{data.world_id}/#{data.stage_id}"


@MetadataCtrl.$inject = ['$scope', '$location', 'Users','Worlds', 'Stages', 'Auth', '$http']
