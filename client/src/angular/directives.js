// Bootstrap the Application
var App = angular.module('App', []);

// This makes any element sortable
// Usage: <div draggable>Foobar</div>
App.directive('sortable', function() {
  return {
    // A = attribute, E = Element, C = Class and M = HTML Comment
    restrict:'A',
    //The link function is responsible for registering DOM listeners as well as updating the DOM.
    link: function(scope, element, attrs) {
      initialArgs = element.attr('sortable')
      argChanged = function(args) {
        console.log(args);
        if (args == "disabled")
          return element.sortable("destroy");
        else if (args == "")
          args = {};
        else
          try { args = JSON.parse(args); } catch (e) { return; }

        args.start = scope.sortable_change_start;
        args.update = scope.sortable_contents_changed;
        element.sortable(args).disableSelection();
      }
      argChanged(initialArgs);
      attrs.$observe('sortable', argChanged);
    }
  };
});


// This makes any element draggable
// Usage: <div draggable>Foobar</div>
App.directive('draggable', function() {
  return {
    // A = attribute, E = Element, C = Class and M = HTML Comment
    restrict:'A',
    //The link function is responsible for registering DOM listeners as well as updating the DOM.
    link: function(scope, element, attrs) {
      args = element.attr('draggable')
      if (args == "")
        args = { opacity: 0.7, helper: "clone" };
      else
        args = JSON.parse(args);
      element.draggable(args);
    }
  };
});

// This makes any element droppable
// Usage: <div droppable></div>
App.directive('droppable', function($compile) {
  return {
    restrict: 'A',
    link: function(scope,element,attrs){
      //This makes an element Droppable
      element.droppable({
        drop:function(event,ui) {
          if (scope.ondrop)
            scope.ondrop(event,ui)
          scope.$apply();
        }
      });
    }
  };
});

// Source: https://github.com/angular/angular.js/issues/1277
// @arcanis
App.directive( [ 'focus', 'blur', 'keyup', 'keydown', 'keypress' ].reduce( function ( container, name ) {
    var directiveName = 'ng' + name[ 0 ].toUpperCase( ) + name.substr( 1 );

    container[ directiveName ] = [ '$parse', function ( $parse ) {
        return function ( scope, element, attr ) {
            var fn = $parse( attr[ directiveName ] );
            element.bind( name, function ( event ) {
                scope.$apply( function ( ) {
                    fn( scope, {
                        $event : event
                    } );
                } );
            } );
        };
    } ];

    return container;
}, { } ) );