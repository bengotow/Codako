(function() {

  this.AppCtrl = function($scope, $location, Users, Stages, Auth, $http) {
    return Auth.withUser(function(error, user) {
      var renderingStage, stagePane1, stagePane2;
      if (!$scope.$$phase) {
        $scope.$apply();
      }
      stagePane1 = new GameStage($("#platformerCanvasPane1")[0]);
      stagePane2 = new GameStage($("#platformerCanvasPane2")[0]);
      renderingStage = new Stage($("#renderingCanvas")[0]);
      window.Socket = io.connect(':4430', {
        secure: false
      });
      window.Socket.on('connect', function() {
        var levelIdentifier;
        console.log('Socket.io Connection Established.');
        window.Socket.emit('auth', {
          username: 'default',
          password: ''
        });
        levelIdentifier = window.location.href.split('#')[1].replace('/', '');
        if (levelIdentifier === void 0) {
          return alert('You need to open a level. Please check the url for #levelIdentifier');
        }
        return window.Game.load(levelIdentifier);
      });
      window.Socket.on('disconnect', function() {
        return console.log('Socket.io Connection Lost. Trying to reconnect...');
      });
      $(document).mousedown(function(e) {
        return window.mouseIsDown = true;
      });
      $(document).mouseup(function(e) {
        return window.mouseIsDown = false;
      });
      window.Game = new GameManager(stagePane1, stagePane2, renderingStage);
      return window.rootScope = angular.element('body').scope();
    });
  };

  this.AppCtrl.$inject = ['$scope', '$location', 'Users', 'Stages', 'Auth', '$http'];

}).call(this);
