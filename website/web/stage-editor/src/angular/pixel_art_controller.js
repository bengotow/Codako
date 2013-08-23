(function() {
  var PixelArtCtrl;

  PixelArtCtrl = function($scope) {
    var b, g, h, r, _i, _ref, _ref1, _ref2, _ref3;
    $scope.actor_definition = null;
    $scope.colors = [];
    $scope.colors.push("rgba(255,255,255,255)");
    $scope.colors.push("rgba(180,180,180,255)");
    $scope.colors.push("rgba(100,100,100,255)");
    $scope.colors.push("rgba(0,0,0,255)");
    for (h = _i = 0; _i <= 70; h = _i += 10) {
      _ref = hsvToRgb(h / 80.0, 1, 1), r = _ref[0], g = _ref[1], b = _ref[2];
      $scope.colors.push("rgba(" + (Math.round(r)) + "," + (Math.round(g)) + "," + (Math.round(b)) + ",255)");
      _ref1 = hsvToRgb(h / 80.0, 0.4, 1), r = _ref1[0], g = _ref1[1], b = _ref1[2];
      $scope.colors.push("rgba(" + (Math.round(r)) + "," + (Math.round(g)) + "," + (Math.round(b)) + ",255)");
      _ref2 = hsvToRgb(h / 80.0, 0.4, 0.75), r = _ref2[0], g = _ref2[1], b = _ref2[2];
      $scope.colors.push("rgba(" + (Math.round(r)) + "," + (Math.round(g)) + "," + (Math.round(b)) + ",255)");
      _ref3 = hsvToRgb(h / 80.0, 1, 0.5), r = _ref3[0], g = _ref3[1], b = _ref3[2];
      $scope.colors.push("rgba(" + (Math.round(r)) + "," + (Math.round(g)) + "," + (Math.round(b)) + ",255)");
    }
    $scope.colorpicker = $('#cp1').colorpicker();
    $scope.colorpicker.show();
    $scope.colorpicker.on('changeColor', function(ev) {
      var c;
      c = ev.color.toRGB();
      return $scope.set_tool_color("rgba(" + c.r + "," + c.g + "," + c.b + "," + c.a + ")");
    });
    $scope.$root.$on('edit_appearance', function(msg, args) {
      var frame, img;
      $scope.actor_definition = args.actor_definition;
      img = $scope.actor_definition.img;
      if ($scope.canvas) {
        $scope.canvas.setImage(img);
      } else {
        $scope.canvas = new PixelArtCanvas(img, $('#pixelArtCanvas')[0], $scope);
      }
      frame = $scope.actor_definition.frameForAppearance(args.identifier);
      $scope.canvas.setDisplayedFrame(frame);
      return $('#pixelArtModal').modal({
        show: true
      });
    });
    $scope.set_tool_color = function(color) {
      $scope.canvas.toolColor = color;
      return $scope.colorpicker.data('colorpicker').setValue(color);
    };
    $scope.copy = function() {
      return $scope.canvas.copy();
    };
    $scope.paste = function() {
      return $scope.canvas.paste();
    };
    $scope.set_tool = function(tool) {
      $scope.canvas.tool.reset();
      return $scope.canvas.tool = tool;
    };
    $scope.css_for_tool = function(tool) {
      if ($scope.canvas.tool === tool) {
        return 'btn-info btn tool icon';
      }
      return 'btn tool icon';
    };
    $scope.close_editor = function() {
      return $scope.canvas.cleanup();
    };
    $scope.save_editor = function() {
      if (!$scope.actor_definition) {
        return;
      }
      $scope.canvas.cleanup();
      $scope.actor_definition.updateImageData($scope.canvas.dataURLRepresentation());
      return $scope.actor_definition.save();
    };
    return $scope.move_editor_to_tile = function(x, y) {
      var saveChanges;
      saveChanges = confirm("Do you want to save your changes to this frame?");
      return $scope.canvas.setDisplayedTile(x, y, saveChanges);
    };
  };

  window.PixelArtCtrl = PixelArtCtrl;

}).call(this);
