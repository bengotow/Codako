(function() {

  this.CommunityCtrl = function($scope, $dialog, Users, Worlds, Comments, Auth, $http) {
    $scope.credentials = false;
    $scope.worlds = [];
    return Worlds.index({}, function(worlds) {
      return $scope.worlds = worlds;
    });
  };

  this.CommunityCtrl.$inject = ['$scope', '$dialog', 'Users', 'Worlds', 'Comments', 'Auth', '$http'];

}).call(this);
