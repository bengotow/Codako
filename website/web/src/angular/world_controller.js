(function() {

  this.WorldCtrl = function($scope, $dialog, $location, $routeParams, Stages, Worlds, Comments, Auth, $http) {
    $scope.world = {
      _id: $routeParams._id
    };
    Worlds.get($scope.world, function(world) {
      return $scope.world = world;
    }, function(error) {
      return $location.path('/home');
    });
    Comments.index({
      world_id: $scope.world._id
    }, function(comments) {
      return $scope.comments = comments;
    });
    $scope.newStage = function() {
      var data;
      data = {
        world_id: $scope.world._id
      };
      return Stages.create(data, function(stage) {
        return $scope.openStage(stage);
      });
    };
    return $scope.openStage = function(stage) {
      return window.location.href = "/editor/#/" + $scope.world._id + "/" + stage._id;
    };
  };

  this.WorldCtrl.$inject = ['$scope', '$dialog', '$location', '$routeParams', 'Stages', 'Worlds', 'Comments', 'Auth', '$http'];

}).call(this);
