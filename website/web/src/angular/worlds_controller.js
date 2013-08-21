(function() {

  this.WorldsCtrl = function($scope, $dialog, $location, Users, Worlds, Comments, Auth, $http) {
    $scope.worlds = [];
    Worlds.mine({}, function(worlds) {
      return $scope.worlds = worlds;
    });
    return $scope.newWorld = function() {
      var data;
      data = {
        title: 'Untitled World',
        description: 'A brand new world!'
      };
      return Worlds.create(data, function(world) {
        return $location.path("/world/" + world._id);
      });
    };
  };

  this.WorldsCtrl.$inject = ['$scope', '$dialog', '$location', 'Users', 'Worlds', 'Comments', 'Auth', '$http'];

}).call(this);
