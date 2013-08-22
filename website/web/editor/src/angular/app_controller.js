(function() {

  this.AppCtrl = function($scope, $location, Users, Stages, Auth, $http) {
    return Auth.withUser(function(error, user) {
      var path, renderingStage, stagePane1, stagePane2, stage_id, world_id;
      if (error || !user) {
        alert('You need to log in!');
      }
      if (!$scope.$$phase) {
        $scope.$apply();
      }
      stagePane1 = new GameStage($("#platformerCanvasPane1")[0]);
      stagePane2 = new GameStage($("#platformerCanvasPane2")[0]);
      renderingStage = new Stage($("#renderingCanvas")[0]);
      $(document).on('mousedown', function(e) {
        window.mouseIsDown = true;
        return true;
      });
      $(document).on('mouseup', function(e) {
        window.mouseIsDown = false;
        return true;
      });
      window.Game = new GameManager(stagePane1, stagePane2, renderingStage);
      window.rootScope = angular.element('body').scope();
      path = window.location.href.split('#')[1];
      if (path) {
        path = path.split('/');
        stage_id = path[path.length - 1];
        world_id = path[path.length - 2];
      }
      if (!stage_id || !world_id) {
        window.location.href = "/";
      }
      return window.Game.load(world_id, stage_id);
    });
  };

  this.AppCtrl.$inject = ['$scope', '$location', 'Users', 'Stages', 'Auth', '$http'];

}).call(this);
