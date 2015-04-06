var App = angular.module('App')

App.directive("timeAgo", function($compile) {
  return {
    restrict: "C",
    link: function(scope, element, attrs) {
      jQuery(element).timeago();
    }
  };
});

App.filter("timeAgo", function() {
  return function(date) {
    return jQuery.timeago(date); 
  };
});