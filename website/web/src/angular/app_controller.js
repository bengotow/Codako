(function() {

  this.AppCtrl = function($scope, $dialog, $location, Users, Stages, Comments, Auth, $http) {
    $scope.navigationItems = [];
    Auth.withUser(function(error, user) {
      if (!$scope.$$phase) {
        return $scope.$apply();
      }
    });
    $scope.navigationItemMatching = function(label, href) {
      var item, _i, _len, _ref;
      if (href == null) {
        href = '#';
      }
      _ref = $scope.navigationItems;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        if (item.label === label) {
          return item;
        }
      }
      item = {
        label: label,
        href: href
      };
      $scope.navigationItems.push(item);
      return item;
    };
    $scope.rebuildNavigationClasses = function(items) {
      var item, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        if ($location.$$path.indexOf(item.href) !== -1) {
          _results.push(item["class"] = 'active');
        } else {
          _results.push(item["class"] = '');
        }
      }
      return _results;
    };
    return $scope.navigation = function(side) {
      var items;
      items = [];
      if (side === 'left') {
        if (Auth.user()) {
          items.push($scope.navigationItemMatching('My Worlds', 'worlds'));
        }
        items.push($scope.navigationItemMatching('Home', 'home'));
        items.push($scope.navigationItemMatching('Community', 'community'));
        items.push($scope.navigationItemMatching('Parents', 'parents'));
        $scope.rebuildNavigationClasses(items);
        return items;
      }
      if (side === 'right') {
        if (Auth.user()) {
          items.push($scope.navigationItemMatching('Sign Out', 'sign-out'));
        } else {
          items.push($scope.navigationItemMatching('Create Account', 'sign-up'));
          items.push($scope.navigationItemMatching('Sign In', 'sign-in'));
        }
        $scope.rebuildNavigationClasses(items);
        return items;
      }
    };
  };

  this.AppCtrl.$inject = ['$scope', '$dialog', '$location', 'Users', 'Stages', 'Comments', 'Auth', '$http'];

}).call(this);
