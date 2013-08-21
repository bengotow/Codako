(function() {

  this.WorldCtrl = function($scope, $dialog, $location, $routeParams, Stages, Worlds, Comments, Auth, $http) {
    $scope.world = {
      id: $routeParams.id
    };
    Worlds.get($scope.world, function(world) {
      return $scope.world = world;
    }, function(error) {
      return $location.path('/home');
    });
    Comments.index({
      world_id: $scope.world.id
    }, function(comments) {
      return $scope.comments = comments;
    });
    $scope.newStage = function() {
      var data;
      data = {
        world_id: $scope.world.id
      };
      return Stages.create(data, function(stage) {
        return $scope.openStage(stage);
      });
    };
    return $scope.openStage = function(stage) {
      return window.location.href = "/editor/#/" + $scope.world.id + "/" + stage.id;
    };
  };

  this.WorldCtrl.$inject = ['$scope', '$dialog', '$location', '$routeParams', 'Stages', 'Worlds', 'Comments', 'Auth', '$http'];

}).call(this);
