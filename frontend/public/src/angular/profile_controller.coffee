@ProfileCtrl = ($scope, $dialog, $location, $routeParams, Users, Worlds, Comments, Auth, $http) ->

  $scope.worlds = []
  $scope.user_is_self = false
  $scope.user = null

  if $routeParams.nickname
    Users.get {_id: $routeParams.nickname}, (user) ->
      $scope.setUser(user)
      Auth.withUser (err, me) ->
        $scope.user_is_self = true if me._id == user._id

  else
    Auth.withUser (err, user) ->
      $scope.user_is_self = true
      $scope.setUser(user)


  $scope.setUser = (user) ->
    $scope.user = user
    Worlds.index {user_id: user._id}, (worlds) ->
      $scope.worlds = worlds


  $scope.newWorld = ->
    data = {}
    Worlds.create data, (world) ->
      $location.path("/world/#{world._id}")


  $scope.deleteWorld = (world) ->
    if confirm("Are you sure you want to delete your world '#{world.title}'? You can't undo this!")
      Worlds.destroy {_id: world._id}, ()->
        $scope.worlds.splice($scope.worlds.indexOf(world), 1)


  $scope.importWorld = ->
    input = prompt("Please paste the JSON you exported below.", "")
    return unless input && input.length > 0

    try
      input = JSON.parse(input)
      Worlds.import input, (world) ->
        $scope.worlds.push(world)
    catch err
      alert("Uhoh - that wasn't valid JSON! #{err}")



@ProfileCtrl.$inject = ['$scope', '$dialog', '$location', '$routeParams', 'Users', 'Worlds', 'Comments', 'Auth', '$http']
