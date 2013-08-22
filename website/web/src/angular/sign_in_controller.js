(function() {

  this.SignInCtrl = function($scope, $location, $dialog, Users, Stages, Comments, Auth, $http) {
    $scope.credentials = {
      email: '',
      password: ''
    };
    $scope.registration = {
      email: '',
      password: '',
      password_confirm: '',
      nickname: '',
      terms_agreement: false
    };
    if ($location.path() === '/sign-out') {
      Auth.clearCredentials();
      $location.path('/sign-in');
    }
    Auth.withUser(function(error, user) {
      if (user) {
        return $location.path('/home');
      }
    });
    $scope.signUp = function() {
      var data;
      data = _.clone($scope.registration);
      data.password = CryptoJS.MD5(data.password);
      return Users.create(data, function(user) {
        return alert(JSON.stringify(user));
      });
    };
    return $scope.signIn = function() {
      Auth.setCredentials($scope.credentials.email, CryptoJS.MD5($scope.credentials.password));
      return Auth.withUser(function(error, user) {
        if (error) {
          return alert(error);
        }
        return $location.path('/worlds');
      });
    };
  };

  this.SignInCtrl.$inject = ['$scope', '$location', '$dialog', 'Users', 'Stages', 'Comments', 'Auth', '$http'];

}).call(this);
