(function() {

  this.ProfileCtrl = function($scope, $dialog, $location, Users, Worlds, Comments, Auth, $http) {
    $scope.worlds = [];
    Worlds.mine({}, function(worlds) {
      $scope.worlds = worlds;
      return $scope.user = function() {
        return Auth.user();
      };
    });
    return $scope.new_world = function() {
      var data;
      data = {};
      return Worlds.create(data, function(world) {
        return $location.path("/world/" + world._id);
      });
    };
  };

  this.ProfileCtrl.$inject = ['$scope', '$dialog', '$location', 'Users', 'Worlds', 'Comments', 'Auth', '$http'];

}).call(this);
