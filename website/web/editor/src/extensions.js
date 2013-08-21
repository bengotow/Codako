(function() {

  Math.createUUID = function() {
    return '_' + Math.floor((1 + Math.random()) * 0x10000).toString(6);
  };

  Array.matrix = function(m, n, initial) {
    var a, i, j, mat;
    a = void 0;
    i = void 0;
    j = void 0;
    mat = [];
    i = 0;
    while (i < m) {
      a = [];
      j = 0;
      while (j < n) {
        a[j] = initial;
        j += 1;
      }
      mat[i] = a;
      i += 1;
    }
    return mat;
  };

  Math.clamp = function(value, min, max) {
    value = (value > max ? max : value);
    value = (value < min ? min : value);
    return value;
  };

  Math.applyOperation = function(existing, operation, value) {
    if (operation === 'add') {
      return existing / 1 + value / 1;
    }
    if (operation === 'subtract') {
      return existing / 1 - value / 1;
    }
    if (operation === 'set') {
      return value / 1;
    }
    throw "Don't know how to apply operation " + existing + ", " + operation + ", " + value;
  };

  Point.fromString = function(str) {
    var components;
    components = str.split(',');
    return new Point(components[0] / 1, components[1] / 1);
  };

  Point.fromHash = function(hash) {
    if (hash.x === void 0) {
      throw "Attempt to convert from hash to Point when source is not a hash: " + hash;
    }
    return new Point(hash.x, hash.y);
  };

  Point.isZero = function(coord) {
    return coord.x === 0 && coord.y === 0;
  };

  Point.sum = function(a, b) {
    return new Point(a.x + b.x, a.y + b.y);
  };

  Point.dif = function(a, b) {
    return new Point(a.x - b.x, a.y - b.y);
  };

  Point.prototype.isInside = function(rect) {
    return rect.left <= this.x && rect.top <= this.y && rect.right >= this.x && rect.bottom >= this.y;
  };

  Point.prototype.isEqual = function(coord) {
    return coord.x === this.x && coord.y === this.y;
  };

  window.hsvToRgb = function(h, s, v) {
    var b, f, g, i, p, q, r, t;
    r = g = b = 0;
    i = Math.floor(h * 6);
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);
    switch (i % 6) {
      case 0:
        r = v;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = v;
        b = p;
        break;
      case 2:
        r = p;
        g = v;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = v;
        break;
      case 4:
        r = t;
        g = p;
        b = v;
        break;
      case 5:
        r = v;
        g = p;
        b = q;
    }
    return [r * 255, g * 255, b * 255];
  };

  window.withTempCanvas = function(w, h, func) {
    var canvas, ret;
    canvas = document.createElement("canvas");
    canvas.width = w;
    canvas.height = h;
    document.body.appendChild(canvas);
    ret = func(canvas, canvas.getContext("2d"));
    document.body.removeChild(canvas);
    return ret;
  };

}).call(this);
