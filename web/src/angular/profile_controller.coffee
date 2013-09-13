@ProfileCtrl = ($scope, $dialog, $location, Users, Worlds, Comments, Auth, $http) ->

  $scope.worlds = []
  Worlds.mine {}, (worlds) ->
    $scope.worlds = worlds

  $scope.user = () ->
    Auth.user()

  $scope.newWorld = () ->
    data = {}
    Worlds.create data, (world) ->
      $location.path("/world/#{world._id}")

  $scope.deleteWorld = (world) ->
    if confirm("Are you sure you want to delete your world '#{world.title}'? You can't undo this!")
      Worlds.destroy {_id: world._id}, ()->
        $scope.worlds.splice($scope.worlds.indexOf(world), 1)


  $scope.importWorld = () ->
    input = prompt("Please paste the JSON you exported below.", "")
    try
      input = JSON.parse(input)
    catch err
      alert("Uhoh - that wasn't valid JSON! #{err}")

    Worlds.import input, (world) ->
      $scope.worlds.push(world)



@ProfileCtrl.$inject = ['$scope', '$dialog', '$location', 'Users', 'Worlds', 'Comments', 'Auth', '$http']
