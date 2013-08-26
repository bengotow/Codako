// Bootstrap the Application
var App = angular.module('App', ['ngResource', '$strap.directives', 'ngCookies', 'ui.bootstrap'])

App.config(function($routeProvider) {
  $routeProvider.
    when('/sign-in', {controller:SignInCtrl, templateUrl:'/src/views/sign-in.html'}).
    when('/sign-up', {controller:SignInCtrl, templateUrl:'/src/views/sign-up.html'}).
    when('/sign-out',{controller:SignInCtrl, templateUrl:'/src/views/sign-in.html'}).

    when('/community',{controller:CommunityCtrl, templateUrl:'/src/views/community.html'}).

    when('/profile',    {controller:ProfileCtrl, templateUrl:'/src/views/profile.html'}).
    when('/world/:_id', {controller:WorldCtrl, templateUrl:'/src/views/world.html'}).

    when('/home',{controller:AppCtrl, templateUrl:'/src/views/home.html'}).
    when('/parents',{controller:AppCtrl, templateUrl:'/src/views/parents.html'}).

    otherwise({redirectTo:'/home'})
})

App.config(['$httpProvider', function ($httpProvider) {
  $httpProvider.defaults.headers['common']['Accept'] = 'application/json'
}])

