var App = angular.module('App')

App.factory('Users', ['$resource', function($resource) {
  return $resource('/api/v0/users/:id/:action', {}, {
    me:       { method: 'GET', params: {id: "me" }, isArray: false},
    index:    { method: 'GET', isArray: true},
    get:      { method: 'GET' },
    update:   { method: 'PUT' },
    create:   { method: 'POST' }
  })
}])

App.factory('Worlds', ['$resource', function($resource) {
  return $resource('/api/v0/worlds/:id', {}, {
    get:      { method: 'GET'},
    mine:     { method: 'GET', params: {id: "mine"}, isArray: true },
    popular:  { method: 'GET', params: {id: "popular"}, isArray: true },
    update:   { method: 'PUT', params: {id: "@id"}},
    create:   { method: 'POST' }
  })
}])

App.factory('Stages', ['$resource', function($resource) {
  return $resource('/api/v0/worlds/:world_id/stages/:id', {}, {
    index:    { method: 'GET', params: {world_id: "@world_id"}, isArray: true },
    get:      { method: 'GET', params: {id: "@id", world_id: "@world_id"}},
    update:   { method: 'PUT', params: {id: "@id", world_id: "@world_id"}},
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

App.factory('Auth', ['Base64', 'Users', '$cookieStore', '$http', function (Base64, Users, $cookieStore, $http) {
    // initialize to whatever is in the cookie, if anything
    $http.defaults.headers.common.Authorization = 'Basic ' + $cookieStore.get('authdata');
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
            return callback(null, loadedUser);

          if (!$cookieStore.get('authdata'))
            return null;

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