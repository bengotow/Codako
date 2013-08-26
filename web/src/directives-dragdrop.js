var App = angular.module('App')

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

      args['start'] = function(){
        $(this).data("origPosition",$(this).position());
      }
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
      args = element.attr('droppable')
      if (args == "")
        args = { opacity: 0.7, helper: "clone" };
      else
        args = JSON.parse(args);

      args['drop'] = function(event,ui) {
        dropScope = angular.element(event.target).scope()
        if (dropScope.ondrop)
          if (!dropScope.ondrop(event,ui))
            ui.draggable.animate(ui.draggable.data("origPosition"),0);

        dropScope.$apply();
      }

      element.droppable(args);
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


App.factory('Base64', function() {
    var keyStr = 'ABCDEFGHIJKLMNOP' +
        'QRSTUVWXYZabcdef' +
        'ghijklmnopqrstuv' +
        'wxyz0123456789+/' +
        '=';
    return {
        encode: function (input) {
            var output = "";
            var chr1, chr2, chr3 = "";
            var enc1, enc2, enc3, enc4 = "";
            var i = 0;
 
            do {
                chr1 = input.charCodeAt(i++);
                chr2 = input.charCodeAt(i++);
                chr3 = input.charCodeAt(i++);
 
                enc1 = chr1 >> 2;
                enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
                enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
                enc4 = chr3 & 63;
 
                if (isNaN(chr2)) {
                    enc3 = enc4 = 64;
                } else if (isNaN(chr3)) {
                    enc4 = 64;
                }
 
                output = output +
                    keyStr.charAt(enc1) +
                    keyStr.charAt(enc2) +
                    keyStr.charAt(enc3) +
                    keyStr.charAt(enc4);
                chr1 = chr2 = chr3 = "";
                enc1 = enc2 = enc3 = enc4 = "";
            } while (i < input.length);
 
            return output;
        },
 
        decode: function (input) {
            var output = "";
            var chr1, chr2, chr3 = "";
            var enc1, enc2, enc3, enc4 = "";
            var i = 0;
 
            // remove all characters that are not A-Z, a-z, 0-9, +, /, or =
            var base64test = /[^A-Za-z0-9\+\/\=]/g;
            if (base64test.exec(input)) {
                alert("There were invalid base64 characters in the input text.\n" +
                    "Valid base64 characters are A-Z, a-z, 0-9, '+', '/',and '='\n" +
                    "Expect errors in decoding.");
            }
            input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
 
            do {
                enc1 = keyStr.indexOf(input.charAt(i++));
                enc2 = keyStr.indexOf(input.charAt(i++));
                enc3 = keyStr.indexOf(input.charAt(i++));
                enc4 = keyStr.indexOf(input.charAt(i++));
 
                chr1 = (enc1 << 2) | (enc2 >> 4);
                chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
                chr3 = ((enc3 & 3) << 6) | enc4;
 
                output = output + String.fromCharCode(chr1);
 
                if (enc3 != 64) {
                    output = output + String.fromCharCode(chr2);
                }
                if (enc4 != 64) {
                    output = output + String.fromCharCode(chr3);
                }
 
                chr1 = chr2 = chr3 = "";
                enc1 = enc2 = enc3 = enc4 = "";
 
            } while (i < input.length);
 
            return output;
        }
    };
});
