(function() {

  this.WorldCtrl = function($scope, $dialog, $location, $routeParams, Stages, Worlds, Comments, Auth, $http) {
    $scope.world = {
      _id: $routeParams._id
    };
    Worlds.get($scope.world, function(world) {
      $scope.world = world;
      Stages.index({
        world_id: $scope.world._id
      }, function(stages) {
        return $scope.stages = stages;
      });
      return Comments.index({
        world_id: $scope.world._id
      }, function(comments) {
        return $scope.comments = comments;
      });
    }, function(error) {
      return $location.path('/home');
    });
    $scope.newStage = function() {
      return Stages.create({
        world_id: $scope.world._id
      }, function(stage) {
        return $scope.openStage(stage);
      });
    };
    return $scope.openStage = function(stage) {
      return window.location.href = "/stage-editor/#/" + $scope.world._id + "/" + stage._id;
    };
  };

  this.WorldCtrl.$inject = ['$scope', '$dialog', '$location', '$routeParams', 'Stages', 'Worlds', 'Comments', 'Auth', '$http'];

}).call(this);
