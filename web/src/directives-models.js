var App = angular.module('App')

App.factory('Users', ['$resource', function($resource) {
  return $resource('/api/v0/users/:_id/:action', {}, {
    me:       { method: 'GET', params: {_id: "me" }, isArray: false},
    index:    { method: 'GET', isArray: true},
    get:      { method: 'GET', params: {_id: "@_id"}},
    update:   { method: 'PUT' },
    create:   { method: 'POST' }
  })
}])

App.factory('Worlds', ['$resource', function($resource) {
  return $resource('/api/v0/worlds/:_id', {}, {
    index:    { method: 'GET', url: '/api/v0/users/:user_id/worlds', params: {user_id: "@user_id"}, isArray: true },
    popular:  { method: 'GET', params: {_id: "popular"}, isArray: true },
    get:      { method: 'GET', params: {_id: "@_id"} },
    update:   { method: 'PUT', params: {_id: "@_id"}},
    destroy:  { method: 'DELETE', params: {_id: "@_id"}},
    create:   { method: 'POST' },
    import:   { method: 'POST', params: {_id: "import"}}
  })
}])

App.factory('Stages', ['$resource', function($resource) {
  return $resource('/api/v0/worlds/:world_id/stages/:id', {}, {
    index:    { method: 'GET', params: {world_id: "@world_id"}, isArray: true },
    get:      { method: 'GET', params: {id: "@_id", world_id: "@world_id"}},
    update:   { method: 'PUT', params: {id: "@_id", world_id: "@world_id"}},
    create:   { method: 'POST', params: {world_id: "@world_id"}}
  })
}])

App.factory('Comments', ['$resource', function($resource) {
  return $resource('/api/v0/worlds/:world_id/comments/:id', {}, {
    index:    { method: 'GET', params: {world_id: "@world_id"}, isArray: true },
    get:      { method: 'GET'},
    update:   { method: 'PUT'},
    create:   { method: 'POST'}
  })
}])

App.factory('Auth', ['Base64', 'Users', '$cookieStore','$timeout', '$http', function (Base64, Users, $cookieStore, $timeout, $http) {
    // initialize to whatever is in the cookie, if anything
    $http.defaults.headers.common.Authorization = 'Basic ' + $cookieStore.get('authdata');
    $.ajaxSetup({headers: { 'Authorization': $http.defaults.headers.common.Authorization }});
    var loadedUser = null;

    return {
        setCredentials: function (username, password) {
          var encoded = Base64.encode(username + ':' + password);
          $cookieStore.put('authdata', encoded);
          // get headers put on all angular requests
          $http.defaults.headers.common.Authorization = 'Basic ' + encoded;
          // get headers put on all jquery requests
          $.ajaxSetup({headers: { 'Authorization': $http.defaults.headers.common.Authorization }});
        },

        user: function() {
          return loadedUser;
        },

        withUser: function(callback) {
          if (loadedUser)
            return $timeout(function() {callback(null, loadedUser);}, 0)

          if (!$cookieStore.get('authdata'))
            return $timeout(function() {callback(null, null);}, 0)

          Users.me({}, function(user) {
              loadedUser = user;
              callback(null, user);
          }, function(result) {
            loadedUser = null
            callback(result.data.error, null)
          });
        },

        clearCredentials: function () {
            document.execCommand("ClearAuthenticationCache");
            $cookieStore.remove('authdata');
            $.ajaxSetup({headers: { 'Authorization': '' }});
            $http.defaults.headers.common.Authorization = 'Basic ';
            loadedUser = null;
        }
    };
}]);