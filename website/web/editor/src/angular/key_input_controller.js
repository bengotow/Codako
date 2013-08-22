(function() {
  var KeyInputCtrl;

  KeyInputCtrl = function($scope) {
    $scope.key_code = false;
    $scope.visible = false;
    $scope.done_callback = null;
    $scope.$root.$on('edit_key', function(msg, args) {
      $scope.key_code = args.key_code;
      $scope.visible = true;
      $scope.done_callback = args.completion_callback;
      $('#keyInputModal').modal({
        show: true
      });
      return $scope.redraw();
    });
    $('body').keydown(function(event) {
      if (!$scope.visible) {
        return true;
      }
      $scope.key_code = event.keyCode;
      $scope.$apply();
      $scope.redraw();
      return event.preventDefault();
    });
    $scope.redraw = function() {
      var context, drawingCanvas, h, key, map, row, u, v, value, w, x, y, yy, _i, _j, _k, _len, _len1, _len2;
      drawingCanvas = document.getElementById('keyInputCanvas');
      if (drawingCanvas.getContext) {
        context = drawingCanvas.getContext('2d');
        map = [
          [
            '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '+', {
              length: 1.65,
              value: '—'
            }
          ], [
            {
              length: 1.65,
              value: 9
            }, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '\\'
          ], [
            {
              length: 1.87,
              value: '—'
            }, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', ',', {
              length: 1.85,
              value: 13
            }
          ], [
            {
              length: 2.45,
              value: '—'
            }, 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', {
              length: 2.45,
              value: '—'
            }
          ], [
            '—', '—', '—', {
              length: 1.6,
              value: '—'
            }, {
              length: 5,
              value: 32
            }, {
              length: 1.6,
              value: '—'
            }, '—', {
              length: 1,
              value: [null, 37]
            }, {
              length: 1,
              value: [38, 40]
            }, {
              length: 1,
              value: [null, 39]
            }
          ]
        ];
        x = 0;
        y = 0;
        u = drawingCanvas.width / 15.9;
        for (_i = 0, _len = map.length; _i < _len; _i++) {
          row = map[_i];
          for (_j = 0, _len1 = row.length; _j < _len1; _j++) {
            key = row[_j];
            w = Math.round(u * key.length);
            value = key.value || key;
            if (!(value instanceof Array)) {
              value = [value];
            }
            h = Math.round((u - 3 * (value.length - 1)) / value.length);
            yy = 0;
            for (_k = 0, _len2 = value.length; _k < _len2; _k++) {
              v = value[_k];
              if (v === '—') {
                context.fillStyle = '#eee';
              } else if ($scope.key_code === v || String.fromEventKeyCode($scope.key_code) === v) {
                context.fillStyle = 'blue';
              } else {
                context.fillStyle = '#ccc';
              }
              if (v !== null) {
                context.fillRect(x, y + yy, w, h);
              }
              yy += h + 3;
            }
            x += w + 3;
          }
          y += u + 3;
          x = 0;
        }
      }
      return false;
    };
    $scope.html_for_key_code = function() {
      if ($scope.key_code === 37) {
        return '<i class="icon-arrow-left"></i>';
      } else if ($scope.key_code === 38) {
        return '<i class="icon-arrow-up"></i>';
      } else if ($scope.key_code === 39) {
        return '<i class="icon-arrow-right"></i>';
      } else if ($scope.key_code === 40) {
        return '<i class="icon-arrow-down"></i>';
      } else {
        return String.fromEventKeyCode($scope.key_code);
      }
    };
    $scope.cancel = function() {
      return $scope.visible = false;
    };
    return $scope.done = function() {
      $scope.visible = false;
      if ($scope.done_callback) {
        return $scope.done_callback($scope.key_code);
      }
    };
  };

  window.KeyInputCtrl = KeyInputCtrl;

}).call(this);
