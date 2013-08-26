(function() {

  this.WorldCtrl = function($scope, $dialog, $location, $routeParams, Stages, Worlds, Comments, Auth, $http) {
    $scope.world = {
      _id: $routeParams._id
    };
    $scope.edit_details_callback = null;
    $scope.edit_message = null;
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
    $scope.new_stage = function() {
      return Stages.create({
        world_id: $scope.world._id
      }, function(stage) {
        return $scope.openStage(stage);
      });
    };
    $scope.open_stage = function(stage) {
      return window.location.href = "/stage-editor/#/" + $scope.world._id + "/" + stage._id;
    };
    $scope.edit_details = function() {
      return $('#editDetailsModal').modal({
        show: true
      });
    };
    $scope.edit_details_save = function() {
      if ($scope.world.title === '' || $scope.world.title.toLowerCase().indexOf('untitled') !== -1) {
        return alert('Please give your world a title!');
      }
      $('#editDetailsModal').modal('hide');
      if ($scope.edit_details_callback) {
        $scope.edit_details_callback();
        return $scope.edit_details_callback = null;
      } else {
        return Worlds.update($scope.world, function(world) {
          return $scope.world = world;
        });
      }
    };
    $scope.publish = function(force) {
      if (force == null) {
        force = false;
      }
      if ($scope.world.title === "Untitled World" && !force) {
        $scope.edit_details_callback = $scope.publish;
        $scope.edit_message = 'Before you publish your world, please name it!';
        return $scope.edit_details();
      } else {
        $scope.world.published = !$scope.world.published;
        return Worlds.update($scope.world, function(world) {
          $scope.world = world;
          if (world.published) {
            return $('#publishModal').modal({
              show: true
            });
          }
        });
      }
    };
    return $scope.publish_action_text = function() {
      if ($scope.world.published) {
        return 'Unpublish';
      } else {
        return 'Publish';
      }
    };
  };

  this.WorldCtrl.$inject = ['$scope', '$dialog', '$location', '$routeParams', 'Stages', 'Worlds', 'Comments', 'Auth', '$http'];

}).call(this);
