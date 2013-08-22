(function() {
  var PixelArtCanvas, PixelEraserTool, PixelFillEllipseTool, PixelFillRectTool, PixelFreehandTool, PixelLineTool, PixelMagicSelectionTool, PixelPaintbucketTool, PixelRectSelectionTool, PixelTool, PixelTranslateTool,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  PixelTool = (function() {

    function PixelTool() {
      this.down = false;
      this.name = 'Undefined';
      this.autoApplyChanges = true;
      this.reset();
    }

    PixelTool.prototype.mousedown = function(point, canvas) {
      this.down = true;
      this.s = point;
      return this.e = point;
    };

    PixelTool.prototype.mousemove = function(point, canvas) {
      if (!this.down) {
        return;
      }
      return this.e = point;
    };

    PixelTool.prototype.mouseup = function(point, canvas) {
      if (!this.down) {
        return;
      }
      this.down = false;
      return this.e = point;
    };

    PixelTool.prototype.previewRender = function(context, canvas) {
      return this.render(context, canvas);
    };

    PixelTool.prototype.render = function(context) {};

    PixelTool.prototype.renderLine = function(context, x0, y0, x1, y1, color, method) {
      var dx, dy, e2, err, sx, sy;
      if (color == null) {
        color = null;
      }
      if (method == null) {
        method = null;
      }
      method || (method = context.fillPixel);
      dx = Math.abs(x1 - x0);
      dy = Math.abs(y1 - y0);
      if (x0 < x1) {
        sx = 1;
      } else {
        sx = -1;
      }
      if (y0 < y1) {
        sy = 1;
      } else {
        sy = -1;
      }
      err = dx - dy;
      while (true) {
        method(x0, y0, color);
        if (x0 === x1 && y0 === y1) {
          return;
        }
        e2 = 2 * err;
        if (e2 > -dy) {
          err = err - dy;
          x0 = x0 + sx;
        }
        if (e2 < dx) {
          err = err + dx;
          y0 = y0 + sy;
        }
      }
    };

    PixelTool.prototype.reset = function() {
      return this.s = this.e = null;
    };

    return PixelTool;

  })();

  PixelFillRectTool = (function(_super) {

    __extends(PixelFillRectTool, _super);

    function PixelFillRectTool() {
      PixelFillRectTool.__super__.constructor.apply(this, arguments);
      this.name = 'rect';
    }

    PixelFillRectTool.prototype.render = function(context) {
      var x, y, _i, _ref, _ref1, _results;
      if (!(this.s && this.e)) {
        return;
      }
      _results = [];
      for (x = _i = _ref = this.s.x, _ref1 = this.e.x; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; x = _ref <= _ref1 ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref2, _ref3, _results1;
          _results1 = [];
          for (y = _j = _ref2 = this.s.y, _ref3 = this.e.y; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; y = _ref2 <= _ref3 ? ++_j : --_j) {
            _results1.push(context.fillPixel(x, y));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return PixelFillRectTool;

  })(PixelTool);

  PixelPaintbucketTool = (function(_super) {

    __extends(PixelPaintbucketTool, _super);

    function PixelPaintbucketTool() {
      PixelPaintbucketTool.__super__.constructor.apply(this, arguments);
      this.name = 'paintbucket';
    }

    PixelPaintbucketTool.prototype.render = function(context, canvas) {
      if (!this.e) {
        return;
      }
      return canvas.getContiguousPixels(this.e, canvas.selectedPixels, function(p) {
        return context.fillPixel(p.x, p.y);
      });
    };

    return PixelPaintbucketTool;

  })(PixelTool);

  PixelFillEllipseTool = (function(_super) {

    __extends(PixelFillEllipseTool, _super);

    function PixelFillEllipseTool() {
      PixelFillEllipseTool.__super__.constructor.apply(this, arguments);
      this.name = 'ellipse';
    }

    PixelFillEllipseTool.prototype.render = function(context) {
      var cx, cy, rx, ry, x, y, _i, _ref, _ref1, _results;
      if (!(this.s && this.e)) {
        return;
      }
      rx = (this.e.x - this.s.x) / 2;
      ry = (this.e.y - this.s.y) / 2;
      cx = Math.round(this.s.x + rx);
      cy = Math.round(this.s.y + ry);
      _results = [];
      for (x = _i = _ref = this.s.x, _ref1 = this.e.x; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; x = _ref <= _ref1 ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref2, _ref3, _results1;
          _results1 = [];
          for (y = _j = _ref2 = this.s.y, _ref3 = this.e.y; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; y = _ref2 <= _ref3 ? ++_j : --_j) {
            if (Math.pow((x - cx) / rx, 2) + Math.pow((y - cy) / ry, 2) < 1) {
              _results1.push(context.fillPixel(x, y));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return PixelFillEllipseTool;

  })(PixelTool);

  PixelFreehandTool = (function(_super) {

    __extends(PixelFreehandTool, _super);

    function PixelFreehandTool() {
      PixelFreehandTool.__super__.constructor.apply(this, arguments);
      this.name = 'pen';
    }

    PixelFreehandTool.prototype.mousedown = function(point) {
      this.down = true;
      return this.points.push(point);
    };

    PixelFreehandTool.prototype.mousemove = function(point) {
      if (!this.down) {
        return;
      }
      return this.points.push(point);
    };

    PixelFreehandTool.prototype.mouseup = function(point) {
      if (!this.down) {
        return;
      }
      this.down = false;
      return this.points.push(point);
    };

    PixelFreehandTool.prototype.reset = function() {
      return this.points = [];
    };

    PixelFreehandTool.prototype.render = function(context) {
      var point, prev, _i, _len, _ref, _results;
      if (!this.points.length) {
        return;
      }
      prev = this.points[0];
      _ref = this.points;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        this.renderLine(context, prev.x, prev.y, point.x, point.y);
        _results.push(prev = point);
      }
      return _results;
    };

    return PixelFreehandTool;

  })(PixelTool);

  PixelLineTool = (function(_super) {

    __extends(PixelLineTool, _super);

    function PixelLineTool() {
      PixelLineTool.__super__.constructor.apply(this, arguments);
      this.name = 'line';
    }

    PixelLineTool.prototype.render = function(context) {
      if (!(this.s && this.e)) {
        return;
      }
      return this.renderLine(context, this.s.x, this.s.y, this.e.x, this.e.y);
    };

    return PixelLineTool;

  })(PixelTool);

  PixelEraserTool = (function(_super) {

    __extends(PixelEraserTool, _super);

    function PixelEraserTool() {
      PixelEraserTool.__super__.constructor.apply(this, arguments);
      this.name = 'eraser';
    }

    PixelEraserTool.prototype.mousedown = function(point) {
      this.down = true;
      return this.points.push(point);
    };

    PixelEraserTool.prototype.mousemove = function(point) {
      if (!this.down) {
        return;
      }
      return this.points.push(point);
    };

    PixelEraserTool.prototype.mouseup = function(point) {
      if (!this.down) {
        return;
      }
      this.down = false;
      return this.points.push(point);
    };

    PixelEraserTool.prototype.reset = function() {
      return this.points = [];
    };

    PixelEraserTool.prototype.previewRender = function(context, canvas) {
      var point, prev, _i, _len, _ref, _results;
      prev = this.points[0];
      _ref = this.points;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        this.renderLine(context, prev.x, prev.y, point.x, point.y, "rgba(0,0,0,0)", context.clearPixel);
        _results.push(prev = point);
      }
      return _results;
    };

    PixelEraserTool.prototype.render = function(context, canvas) {
      var point, prev, _i, _len, _ref, _results;
      if (!this.points.length) {
        return;
      }
      prev = this.points[0];
      _ref = this.points;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        this.renderLine(context, prev.x, prev.y, point.x, point.y, "rgba(0,0,0,0)");
        _results.push(prev = point);
      }
      return _results;
    };

    return PixelEraserTool;

  })(PixelTool);

  PixelRectSelectionTool = (function(_super) {

    __extends(PixelRectSelectionTool, _super);

    function PixelRectSelectionTool() {
      PixelRectSelectionTool.__super__.constructor.apply(this, arguments);
      this.name = 'select';
    }

    PixelRectSelectionTool.prototype.mouseup = function(point) {
      if (!this.down) {
        return;
      }
      this.down = false;
      return this.e = point;
    };

    PixelRectSelectionTool.prototype.render = function(context, canvas) {
      var sel_x, sel_y, _i, _ref, _ref1, _results;
      if (!(this.s && this.e)) {
        return;
      }
      if (!(context instanceof CanvasRenderingContext2D)) {
        return;
      }
      canvas.selectedPixels = [];
      if (this.s.x === this.e.x || this.s.y === this.e.y) {
        return;
      }
      _results = [];
      for (sel_x = _i = _ref = this.s.x, _ref1 = this.e.x - 1; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; sel_x = _ref <= _ref1 ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref2, _ref3, _results1;
          _results1 = [];
          for (sel_y = _j = _ref2 = this.s.y, _ref3 = this.e.y - 1; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; sel_y = _ref2 <= _ref3 ? ++_j : --_j) {
            _results1.push(canvas.selectedPixels.push({
              x: sel_x,
              y: sel_y
            }));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    PixelRectSelectionTool.prototype.reset = function() {
      return this.s = this.e = null;
    };

    return PixelRectSelectionTool;

  })(PixelTool);

  PixelMagicSelectionTool = (function(_super) {

    __extends(PixelMagicSelectionTool, _super);

    function PixelMagicSelectionTool() {
      PixelMagicSelectionTool.__super__.constructor.apply(this, arguments);
      this.name = 'magicWand';
    }

    PixelMagicSelectionTool.prototype.render = function(context, canvas) {
      if (!this.e) {
        return;
      }
      canvas.selectedPixels = [];
      return canvas.getContiguousPixels(this.e, null, function(p) {
        return canvas.selectedPixels.push(p);
      });
    };

    return PixelMagicSelectionTool;

  })(PixelTool);

  PixelTranslateTool = (function(_super) {

    __extends(PixelTranslateTool, _super);

    function PixelTranslateTool() {
      PixelTranslateTool.__super__.constructor.apply(this, arguments);
      this.name = 'translate';
    }

    PixelTranslateTool.prototype.mousedown = function(point, canvas) {
      this.down = true;
      if (!canvas.selectedPixels.length) {
        return;
      }
      canvas.cut();
      return canvas.paste();
    };

    return PixelTranslateTool;

  })(PixelTool);

  PixelArtCanvas = (function() {

    function PixelArtCanvas(image, canvas, controller_scope) {
      this.cleanup = __bind(this.cleanup, this);

      this.getBorderPixels = __bind(this.getBorderPixels, this);

      this.getContiguousPixels = __bind(this.getContiguousPixels, this);

      this.clearPixels = __bind(this.clearPixels, this);

      this.paste = __bind(this.paste, this);

      this.cut = __bind(this.cut, this);

      this.copy = __bind(this.copy, this);

      this.handleCanvasEvent = __bind(this.handleCanvasEvent, this);

      this.handleKeyEvent = __bind(this.handleKeyEvent, this);

      var _this = this;
      this.controller = controller_scope;
      this.canvas = canvas;
      this.width = canvas.width;
      this.height = canvas.height;
      this.image = image;
      this.tools = [new PixelRectSelectionTool(), new PixelMagicSelectionTool(), new PixelTranslateTool(), new PixelFreehandTool(), new PixelEraserTool(), new PixelLineTool(), new PixelFillEllipseTool(), new PixelFillRectTool(), new PixelPaintbucketTool()];
      this.tool = this.tools[0];
      this.toolColor = "rgba(0,0,0,255)";
      this.pixelSize = Math.floor(this.width / Tile.WIDTH);
      canvas.width = this.width;
      canvas.height = this.height;
      canvas.addEventListener('mousedown', this.handleCanvasEvent, false);
      canvas.addEventListener('mousemove', this.handleCanvasEvent, false);
      canvas.addEventListener('mouseup', this.handleCanvasEvent, false);
      canvas.addEventListener('mouseout', this.handleCanvasEvent, false);
      Ticker.addListener(this);
      $('body').keydown(this.handleKeyEvent);
      $(canvas).css('cursor', 'crosshair');
      this.context = canvas.getContext("2d");
      this.context.drawTransparentPattern = function() {
        var x, y, _i, _ref, _results;
        _results = [];
        for (x = _i = 0, _ref = _this.imageData.width; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (y = _j = 0, _ref1 = this.imageData.height; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
              this.context.fillStyle = "rgba(230,230,230,1)";
              this.context.fillRect(x * this.pixelSize, y * this.pixelSize, this.pixelSize / 2, this.pixelSize / 2);
              _results1.push(this.context.fillRect(x * this.pixelSize + this.pixelSize / 2, y * this.pixelSize + this.pixelSize / 2, this.pixelSize / 2, this.pixelSize / 2));
            }
            return _results1;
          }).call(_this));
        }
        return _results;
      };
      this.context.fillPixel = function(x, y, color) {
        if (color == null) {
          color = _this.toolColor;
        }
        if (color.slice(-3) !== ',0)') {
          _this.context.fillStyle = color;
          return _this.context.fillRect(x * _this.pixelSize, y * _this.pixelSize, _this.pixelSize, _this.pixelSize);
        }
      };
      this.context.clearPixel = function(x, y) {
        return _this.context.clearRect(x * _this.pixelSize, y * _this.pixelSize, _this.pixelSize, _this.pixelSize);
      };
      this.inDragMode = false;
      this.dragging = false;
      this.dragData = this.context.createImageData(Tile.WIDTH, Tile.HEIGHT);
      this._extendImageData(this.dragData);
      this.dragData.offsetX = 0;
      this.dragData.offsetY = 0;
      this.dragStart = {
        x: 0,
        y: 0
      };
      this.selectedPixels = [];
      this.setDisplayedFrame(0);
    }

    PixelArtCanvas.prototype.setImage = function(img) {
      this.image = img;
      this.setDisplayedFrame(0);
      return this.render();
    };

    PixelArtCanvas.prototype.setDisplayedFrame = function(index, saveChanges) {
      var _this = this;
      if (saveChanges == null) {
        saveChanges = false;
      }
      this.undoStack = [];
      this.redoStack = [];
      this.inDragMode = false;
      this.image.onload = function() {
        _this.prepareDataForDisplayedFrame();
        return _this.render();
      };
      if (saveChanges) {
        this.image.src = this.dataURLRepresentation();
      }
      this.imageDisplayedFrame = index;
      this.prepareDataForDisplayedFrame();
      return this.render();
    };

    PixelArtCanvas.prototype.stagePointToPixel = function(x, y) {
      return new Point(Math.max(0, Math.min(Math.round(x / this.pixelSize), Tile.WIDTH)), Math.max(0, Math.min(Math.round(y / this.pixelSize), Tile.HEIGHT)));
    };

    PixelArtCanvas.prototype.handleKeyEvent = function(ev) {
      if (this.inDragMode === true) {
        if (ev.keyCode === 13) {
          this.applyPixelsFromDataIgnoreTransparent(this.dragData.data, this.imageData, 0, 0, Tile.WIDTH, Tile.HEIGHT, Tile.WIDTH, Math.floor(this.dragData.offsetX / this.pixelSize), Math.floor(this.dragData.offsetY / this.pixelSize));
          $(this.canvas).css('cursor', 'crosshair');
          this.inDragMode = false;
        }
        if (ev.keyCode === 38) {
          this.dragData.offsetY -= this.pixelSize;
        }
        if (ev.keyCode === 40) {
          this.dragData.offsetY += this.pixelSize;
        }
        if (ev.keyCode === 37) {
          this.dragData.offsetX -= this.pixelSize;
        }
        if (ev.keyCode === 39) {
          this.dragData.offsetX += this.pixelSize;
        }
        this.render();
      }
      if (ev.keyCode === 8 || ev.keyCode === 46) {
        ev.preventDefault();
        if (!this.selectedPixels) {
          return;
        }
        this.undoStack.push(new Uint8ClampedArray(this.imageData.data));
        this.redoStack = [];
        this.clearPixels(this.selectedPixels);
        this.selectedPixels = [];
        this.render();
      }
      if (ev.keyCode === 67 && ev.metaKey) {
        this.copy();
      }
      if (ev.keyCode === 88 && ev.metaKey) {
        this.cut();
      }
      if (ev.keyCode === 86 && ev.metaKey) {
        this.paste();
      }
      if (ev.keyCode === 72) {
        if (!this.dragData) {
          return;
        }
        this.flipPixelsHorizontal(this.dragData.data);
      }
      if (ev.keyCode === 74) {
        if (!this.dragData) {
          return;
        }
        this.flipPixelsVertical(this.dragData.data);
      }
      if (ev.keyCode === 90 && ev.metaKey && ev.shiftKey) {
        ev.preventDefault();
        this.redo();
        if (!window.rootScope.$$phase) {
          return window.rootScope.$apply();
        }
      } else if (ev.keyCode === 90 && ev.metaKey) {
        ev.preventDefault();
        this.undo();
        if (!window.rootScope.$$phase) {
          return window.rootScope.$apply();
        }
      }
    };

    PixelArtCanvas.prototype.handleCanvasEvent = function(ev) {
      var evX, evY, type;
      if (!this.tool) {
        return;
      }
      type = ev.type;
      evX = ev.offsetX;
      evY = ev.offsetY;
      if (this.tool.down && !window.mouseIsDown) {
        type = 'mouseup';
        evX = this.mouseLastOffsetX;
        evY = this.mouseLastOffsetY;
      }
      this.mouseLastOffsetX = evX;
      this.mouseLastOffsetY = evY;
      if (this.inDragMode === false) {
        if (type === 'mouseout' && !this.tool[type]) {
          type = 'mousemove';
        }
        if (this.tool[type]) {
          this.tool[type](this.stagePointToPixel(evX, evY), this);
        }
        if (type === 'mouseup' && this.tool.autoApplyChanges === true) {
          this.applyTool();
        }
        return this.render();
      } else {
        if (type === 'mousedown' && this.dragging === false) {
          this.dragging = true;
          this.dragStart.x = evX - this.dragData.offsetX;
          this.dragStart.y = evY - this.dragData.offsetY;
        }
        if (type === 'mouseup') {
          this.dragging = false;
        }
        if (type === 'mousemove' && this.dragging === true) {
          this.dragData.offsetX = Math.floor((evX - this.dragStart.x) / this.pixelSize) * this.pixelSize;
          this.dragData.offsetY = Math.floor((evY - this.dragStart.y) / this.pixelSize) * this.pixelSize;
        }
        return this.render();
      }
    };

    PixelArtCanvas.prototype.copy = function() {
      var p, _i, _len, _ref;
      this.clipboardData = new Uint8ClampedArray(Tile.WIDTH * Tile.HEIGHT * 4);
      _ref = this.selectedPixels;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        this.clipboardData[(p.y * Tile.WIDTH + p.x) * 4 + 0] = this.imageData.data[(p.y * Tile.WIDTH + p.x) * 4 + 0];
        this.clipboardData[(p.y * Tile.WIDTH + p.x) * 4 + 1] = this.imageData.data[(p.y * Tile.WIDTH + p.x) * 4 + 1];
        this.clipboardData[(p.y * Tile.WIDTH + p.x) * 4 + 2] = this.imageData.data[(p.y * Tile.WIDTH + p.x) * 4 + 2];
        this.clipboardData[(p.y * Tile.WIDTH + p.x) * 4 + 3] = this.imageData.data[(p.y * Tile.WIDTH + p.x) * 4 + 3];
      }
      if (!window.rootScope.$$phase) {
        return window.rootScope.$apply();
      }
    };

    PixelArtCanvas.prototype.cut = function() {
      this.copy();
      return this.clearPixels(this.selectedPixels);
    };

    PixelArtCanvas.prototype.paste = function() {
      if (!this.clipboardData) {
        return;
      }
      this.undoStack.push(new Uint8ClampedArray(this.imageData.data));
      this.redoStack = [];
      $(this.canvas).css('cursor', 'move');
      this.dragData.clearRect(0, 0, Tile.WIDTH, Tile.HEIGHT);
      this.applyPixelsFromData(this.clipboardData, this.dragData, 0, 0, Tile.WIDTH, Tile.HEIGHT);
      this.inDragMode = true;
      this.selectedPixels = [];
      return this.render();
    };

    PixelArtCanvas.prototype.clearPixels = function(pixels) {
      var p, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = pixels.length; _i < _len; _i++) {
        p = pixels[_i];
        _results.push(this.imageData.clearRect(p.x, p.y, p.x + 1, p.y + 1));
      }
      return _results;
    };

    PixelArtCanvas.prototype.tick = function() {
      var _ref;
      if ((_ref = this.selectedPixels) != null ? _ref.length : void 0) {
        return this.render();
      }
    };

    PixelArtCanvas.prototype.render = function() {
      var x, y, _i, _j, _ref, _ref1,
        _this = this;
      this.context.fillStyle = "rgb(255,255,255)";
      this.context.clearRect(0, 0, this.width, this.height);
      this.context.drawTransparentPattern();
      this.applyPixelsFromData(this.imageData.data, this.context);
      if (this.inDragMode === true) {
        this.context.fillStyle = "rgba(0,0,0,0.3)";
        this.context.fillRect(0, 0, this.width, this.height);
        this.context.translate(this.dragData.offsetX, this.dragData.offsetY);
        this.applyPixelsFromData(this.dragData.data, this.context, 0, 0, this.dragData.width, this.dragData.height, this.dragData.width);
        this.context.translate(-this.dragData.offsetX, -this.dragData.offsetY);
      }
      if (this.tool) {
        this.tool.previewRender(this.context, this);
      }
      this.context.lineWidth = 1;
      this.context.strokeStyle = "rgba(70,70,70,.90)";
      this.context.beginPath();
      this.getBorderPixels(this.selectedPixels, function(x, y, left, right, top, bot) {
        var botY, leftX, rightX, topY;
        if ((Math.floor(Ticker.getTime() / 250) + x + y * (Tile.WIDTH + 1)) % 2 === 0) {
          topY = y * _this.pixelSize;
          botY = (y + 1) * _this.pixelSize;
          leftX = x * _this.pixelSize;
          rightX = (x + 1) * _this.pixelSize;
          if (!left) {
            _this.context.moveTo(leftX, topY);
            _this.context.lineTo(leftX, botY);
          }
          if (!right) {
            _this.context.moveTo(rightX, topY);
            _this.context.lineTo(rightX, botY);
          }
          if (!top) {
            _this.context.moveTo(leftX, topY);
            _this.context.lineTo(rightX, topY);
          }
          if (!bot) {
            _this.context.moveTo(leftX, botY);
            return _this.context.lineTo(rightX, botY);
          }
        }
      });
      this.context.stroke();
      this.context.lineWidth = 1;
      this.context.strokeStyle = "rgba(70,70,70,.30)";
      this.context.beginPath();
      for (x = _i = 0, _ref = Tile.WIDTH + 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        this.context.moveTo(x * this.pixelSize + 0.5, 0);
        this.context.lineTo(x * this.pixelSize + 0.5, this.height * this.pixelSize + 0.5);
      }
      for (y = _j = 0, _ref1 = Tile.HEIGHT + 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
        this.context.moveTo(0, y * this.pixelSize + 0.5);
        this.context.lineTo(this.width * this.pixelSize + 0.5, y * this.pixelSize + 0.5);
      }
      return this.context.stroke();
    };

    PixelArtCanvas.prototype.applyTool = function() {
      this.undoStack.push(new Uint8ClampedArray(this.imageData.data));
      this.redoStack = [];
      this.tool.render(this.imageData, this);
      this.tool.reset();
      if (!window.rootScope.$$phase) {
        return window.rootScope.$apply();
      }
    };

    PixelArtCanvas.prototype.applyPixelsFromData = function(data, target, startX, startY, endX, endY, dataWidth, offsetX, offsetY) {
      var a, b, g, r, x, y, _i, _ref, _results;
      if (startX == null) {
        startX = 0;
      }
      if (startY == null) {
        startY = 0;
      }
      if (endX == null) {
        endX = Tile.WIDTH;
      }
      if (endY == null) {
        endY = Tile.HEIGHT;
      }
      if (dataWidth == null) {
        dataWidth = Tile.WIDTH;
      }
      if (offsetX == null) {
        offsetX = 0;
      }
      if (offsetY == null) {
        offsetY = 0;
      }
      _results = [];
      for (x = _i = startX, _ref = endX - 1; startX <= _ref ? _i <= _ref : _i >= _ref; x = startX <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (y = _j = startY, _ref1 = endY - 1; startY <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = startY <= _ref1 ? ++_j : --_j) {
            r = data[(y * dataWidth + x) * 4 + 0];
            g = data[(y * dataWidth + x) * 4 + 1];
            b = data[(y * dataWidth + x) * 4 + 2];
            a = data[(y * dataWidth + x) * 4 + 3];
            _results1.push(target.fillPixel(x + offsetX, y + offsetY, "rgba(" + r + "," + g + "," + b + "," + a + ")"));
          }
          return _results1;
        })());
      }
      return _results;
    };

    PixelArtCanvas.prototype.applyPixelsFromDataIgnoreTransparent = function(data, target, startX, startY, endX, endY, dataWidth, offsetX, offsetY) {
      var a, b, g, r, x, y, _i, _ref, _results;
      if (startX == null) {
        startX = 0;
      }
      if (startY == null) {
        startY = 0;
      }
      if (endX == null) {
        endX = Tile.WIDTH;
      }
      if (endY == null) {
        endY = Tile.HEIGHT;
      }
      if (dataWidth == null) {
        dataWidth = Tile.WIDTH;
      }
      if (offsetX == null) {
        offsetX = 0;
      }
      if (offsetY == null) {
        offsetY = 0;
      }
      _results = [];
      for (x = _i = startX, _ref = endX - 1; startX <= _ref ? _i <= _ref : _i >= _ref; x = startX <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (y = _j = startY, _ref1 = endY - 1; startY <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = startY <= _ref1 ? ++_j : --_j) {
            r = data[(y * dataWidth + x) * 4 + 0];
            g = data[(y * dataWidth + x) * 4 + 1];
            b = data[(y * dataWidth + x) * 4 + 2];
            a = data[(y * dataWidth + x) * 4 + 3];
            if (a > 0) {
              _results1.push(target.fillPixel(x + offsetX, y + offsetY, "rgba(" + r + "," + g + "," + b + "," + a + ")"));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      }
      return _results;
    };

    PixelArtCanvas.prototype.flipPixelsHorizontal = function(data, startX, startY, endX, endY) {
      var channel, indexA, indexB, valueA, width, x, y, _i, _ref, _results;
      if (startX == null) {
        startX = 0;
      }
      if (startY == null) {
        startY = 0;
      }
      if (endX == null) {
        endX = Tile.WIDTH;
      }
      if (endY == null) {
        endY = Tile.HEIGHT;
      }
      width = endX - startX;
      _results = [];
      for (x = _i = startX, _ref = startX + (width / 2); startX <= _ref ? _i <= _ref : _i >= _ref; x = startX <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _results1;
          _results1 = [];
          for (y = _j = startY; startY <= endY ? _j <= endY : _j >= endY; y = startY <= endY ? ++_j : --_j) {
            indexA = (y * width + x) * 4;
            indexB = (y * width + (width - x)) * 4;
            _results1.push((function() {
              var _k, _results2;
              _results2 = [];
              for (channel = _k = 0; _k <= 3; channel = ++_k) {
                valueA = data[indexA + channel];
                data[indexA + channel] = data[indexB + channel];
                _results2.push(data[indexB + channel] = valueA);
              }
              return _results2;
            })());
          }
          return _results1;
        })());
      }
      return _results;
    };

    PixelArtCanvas.prototype.flipPixelsVertical = function(data, startX, startY, endX, endY) {
      var channel, height, indexA, indexB, valueA, width, x, y, _i, _results;
      if (startX == null) {
        startX = 0;
      }
      if (startY == null) {
        startY = 0;
      }
      if (endX == null) {
        endX = Tile.WIDTH;
      }
      if (endY == null) {
        endY = Tile.HEIGHT;
      }
      width = endX - startX;
      height = endY - startY;
      _results = [];
      for (x = _i = startX; startX <= endX ? _i <= endX : _i >= endX; x = startX <= endX ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref, _results1;
          _results1 = [];
          for (y = _j = startY, _ref = startY + (height / 2); startY <= _ref ? _j <= _ref : _j >= _ref; y = startY <= _ref ? ++_j : --_j) {
            indexA = (y * width + x) * 4;
            indexB = ((height - y) * width + x) * 4;
            _results1.push((function() {
              var _k, _results2;
              _results2 = [];
              for (channel = _k = 0; _k <= 3; channel = ++_k) {
                valueA = data[indexA + channel];
                data[indexA + channel] = data[indexB + channel];
                _results2.push(data[indexB + channel] = valueA);
              }
              return _results2;
            })());
          }
          return _results1;
        })());
      }
      return _results;
    };

    PixelArtCanvas.prototype.copyPixelsFromData = function(data, target, startX, startY, endX, endY, dataWidth) {
      var h, w, x, y, _i, _ref, _results;
      if (startX == null) {
        startX = 0;
      }
      if (startY == null) {
        startY = 0;
      }
      if (endX == null) {
        endX = Tile.WIDTH;
      }
      if (endY == null) {
        endY = Tile.HEIGHT;
      }
      if (dataWidth == null) {
        dataWidth = Tile.WIDTH;
      }
      w = endX - startX;
      h = endY - startY;
      _results = [];
      for (x = _i = 0, _ref = w - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (y = _j = 0, _ref1 = h - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            target[(y * w + x) * 4 + 0] = data[((startY + y) * dataWidth + (startX + x)) * 4 + 0];
            target[(y * w + x) * 4 + 1] = data[((startY + y) * dataWidth + (startX + x)) * 4 + 1];
            target[(y * w + x) * 4 + 2] = data[((startY + y) * dataWidth + (startX + x)) * 4 + 2];
            _results1.push(target[(y * w + x) * 4 + 3] = data[((startY + y) * dataWidth + (startX + x)) * 4 + 3]);
          }
          return _results1;
        })());
      }
      return _results;
    };

    PixelArtCanvas.prototype.getContiguousPixels = function(startPixel, region, callback) {
      var colorDelta, d, i, p, pixelData, points, pointsHit, pp, startPixelData, _results;
      points = [startPixel];
      startPixelData = this.imageData.getPixel(startPixel.x, startPixel.y);
      pointsHit = {};
      pointsHit["" + startPixel.x + "-" + startPixel.y] = 1;
      _results = [];
      while ((p = points.pop())) {
        callback(p);
        _results.push((function() {
          var _i, _j, _len, _ref, _results1;
          _ref = [
            {
              x: -1,
              y: 0
            }, {
              x: 0,
              y: 1
            }, {
              x: 0,
              y: -1
            }, {
              x: 1,
              y: 0
            }
          ];
          _results1 = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            d = _ref[_i];
            pp = new Point(p.x + d.x, p.y + d.y);
            if (!(pp.x >= 0 && pp.y >= 0 && pp.x < Tile.WIDTH && pp.y < Tile.HEIGHT)) {
              continue;
            }
            if ((region != null ? region.length : void 0) && !_.find(region, function(test) {
              return pp.x === test.x && pp.y === test.y;
            })) {
              continue;
            }
            if (pointsHit["" + pp.x + "-" + pp.y]) {
              continue;
            }
            pixelData = this.imageData.getPixel(pp.x, pp.y);
            colorDelta = 0;
            for (i = _j = 0; _j <= 3; i = ++_j) {
              colorDelta += Math.abs(pixelData[i] - startPixelData[i]);
            }
            if (colorDelta < 15) {
              points.push(pp);
              _results1.push(pointsHit["" + pp.x + "-" + pp.y] = true);
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    PixelArtCanvas.prototype.getBorderPixels = function(pixels, callback) {
      var bot, left, other, p, right, top, _i, _j, _len, _len1, _results;
      _results = [];
      for (_i = 0, _len = pixels.length; _i < _len; _i++) {
        p = pixels[_i];
        left = right = top = bot = false;
        for (_j = 0, _len1 = pixels.length; _j < _len1; _j++) {
          other = pixels[_j];
          if (other.x === p.x - 1 && other.y === p.y) {
            left = true;
          }
          if (other.x === p.x + 1 && other.y === p.y) {
            right = true;
          }
          if (other.x === p.x && other.y === p.y - 1) {
            top = true;
          }
          if (other.x === p.x && other.y === p.y + 1) {
            bot = true;
          }
        }
        if (!left || !right || !top || !bot) {
          _results.push(callback(p.x, p.y, left, right, top, bot));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PixelArtCanvas.prototype.canCopy = function() {
      return this.selectedPixels.length;
    };

    PixelArtCanvas.prototype.canPaste = function() {
      if (this.clipboardData) {
        return true;
      }
      return false;
    };

    PixelArtCanvas.prototype.canUndo = function() {
      return this.undoStack.length;
    };

    PixelArtCanvas.prototype.undo = function() {
      if (!this.canUndo()) {
        return;
      }
      this.redoStack.push(new Uint8ClampedArray(this.imageData.data));
      this.applyPixelsFromData(this.undoStack.pop(), this.imageData);
      return this.render();
    };

    PixelArtCanvas.prototype.canRedo = function() {
      return this.redoStack.length;
    };

    PixelArtCanvas.prototype.redo = function() {
      if (!this.canRedo()) {
        return;
      }
      this.undoStack.push(new Uint8ClampedArray(this.imageData.data));
      this.applyPixelsFromData(this.redoStack.pop(), this.imageData);
      return this.render();
    };

    PixelArtCanvas.prototype.coordsForFrame = function(frame) {
      var x, y;
      x = frame % (this.image.width / Tile.WIDTH);
      y = Math.floor(frame / (this.image.width / Tile.WIDTH));
      return [x * Tile.WIDTH, y * Tile.HEIGHT];
    };

    PixelArtCanvas.prototype.dataURLRepresentation = function() {
      var totalHeight, totalWidth, url, x, y, _ref,
        _this = this;
      _ref = this.coordsForFrame(this.imageDisplayedFrame), x = _ref[0], y = _ref[1];
      totalWidth = Math.max(this.image.width, x + Tile.WIDTH);
      totalHeight = Math.max(this.image.height, y + Tile.HEIGHT);
      url = false;
      window.withTempCanvas(totalWidth, totalHeight, function(canvas, context) {
        if (_this.image) {
          context.drawImage(_this.image, 0, 0);
        }
        context.putImageData(_this.imageData, x, y);
        return url = canvas.toDataURL();
      });
      return {
        data: url,
        width: totalWidth
      };
    };

    PixelArtCanvas.prototype.prepareDataForDisplayedFrame = function() {
      var _this = this;
      window.withTempCanvas(Tile.WIDTH, Tile.HEIGHT, function(canvas, context) {
        var x, y, _ref;
        _ref = _this.coordsForFrame(_this.imageDisplayedFrame), x = _ref[0], y = _ref[1];
        context.imageSmoothingEnabled = false;
        context.clearRect(0, 0, _this.width, _this.height);
        if (_this.image) {
          context.drawImage(_this.image, -x, -y);
        }
        return _this.imageData = context.getImageData(0, 0, canvas.width, canvas.height);
      });
      this._extendImageData(this.imageData);
      return this.imageData;
    };

    PixelArtCanvas.prototype.cleanup = function() {
      this.inDragMode = false;
      this.dragging = false;
      this.dragData.clearRect(0, 0, Tile.WIDTH, Tile.HEIGHT);
      this.dragStart = {
        x: 0,
        y: 0
      };
      this.selectedPixels = [];
      return this.render();
    };

    PixelArtCanvas.prototype._extendImageData = function(imgData) {
      var _this = this;
      imgData.fillPixel = function(xx, yy, color) {
        var components, i, _i, _ref, _results;
        if (color == null) {
          color = _this.toolColor;
        }
        if (xx >= Tile.WIDTH || xx < 0) {
          return;
        }
        if (yy >= Tile.HEIGHT || yy < 0) {
          return;
        }
        components = color.slice(5, -1).split(',');
        _results = [];
        for (i = _i = 0, _ref = components.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(imgData.data[(yy * Tile.WIDTH + xx) * 4 + i] = components[i] / 1);
        }
        return _results;
      };
      imgData.getPixel = function(xx, yy) {
        var oo;
        oo = (yy * Tile.WIDTH + xx) * 4;
        return [this.data[oo], this.data[oo + 1], this.data[oo + 2], this.data[oo + 3]];
      };
      return imgData.clearRect = function(startX, startY, endX, endY) {
        var x, y, _i, _ref, _results;
        if (!((endX - startX) > 0 && (endY - startY) > 0)) {
          return;
        }
        _results = [];
        for (x = _i = startX, _ref = endX - 1; startX <= _ref ? _i <= _ref : _i >= _ref; x = startX <= _ref ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (y = _j = startY, _ref1 = endY - 1; startY <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = startY <= _ref1 ? ++_j : --_j) {
              _results1.push(this.fillPixel(x, y, 'rgba(0,0,0,0)'));
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };
    };

    return PixelArtCanvas;

  })();

  window.PixelArtCanvas = PixelArtCanvas;

}).call(this);
