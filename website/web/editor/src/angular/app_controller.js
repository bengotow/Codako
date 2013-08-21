(function() {

  this.AppCtrl = function($scope, $location, Users, Stages, Auth, $http) {
    return Auth.withUser(function(error, user) {
      var path, renderingStage, stagePane1, stagePane2;
      if (!$scope.$$phase) {
        $scope.$apply();
      }
      stagePane1 = new GameStage($("#platformerCanvasPane1")[0]);
      stagePane2 = new GameStage($("#platformerCanvasPane2")[0]);
      renderingStage = new Stage($("#renderingCanvas")[0]);
      $(document).mousedown(function(e) {
        return window.mouseIsDown = true;
      });
      $(document).mouseup(function(e) {
        return window.mouseIsDown = false;
      });
      window.Game = new GameManager(stagePane1, stagePane2, renderingStage);
      window.rootScope = angular.element('body').scope();
      path = window.location.href.split('#')[1];
      path = path.split('/');
      return window.Game.load(path[path.length - 2], path[path.length - 1]);
    });
  };

  this.AppCtrl.$inject = ['$scope', '$location', 'Users', 'Stages', 'Auth', '$http'];

}).call(this);
