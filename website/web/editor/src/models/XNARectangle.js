(function() {
  var XNARectangle,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  XNARectangle = (function(_super) {

    __extends(XNARectangle, _super);

    function XNARectangle(x, y, width, height) {
      XNARectangle.__super__.initialize.call(this, x, y, width, height);
      this.Location = new Point(this.x, this.y);
      this.Center = new Point(parseInt(this.x + this.width / 2), parseInt(this.y + this.height / 2));
      this;

    }

    XNARectangle.prototype.left = function() {
      return parseInt(this.x);
    };

    XNARectangle.prototype.right = function() {
      return parseInt(this.x + this.width);
    };

    XNARectangle.prototype.top = function() {
      return parseInt(this.y);
    };

    XNARectangle.prototype.bottom = function() {
      return parseInt(this.y + this.height);
    };

    XNARectangle.prototype.contains = function(targetRectangle) {
      if (this.x <= targetRectangle.x && targetRectangle.x + targetRectangle.width <= this.x + this.width && this.y <= targetRectangle.y) {
        return targetRectangle.y + targetRectangle.height <= this.y + this.height;
      } else {
        return false;
      }
    };

    XNARectangle.prototype.containsPoint = function(targetPoint) {
      if (this.x <= targetPoint.x && targetPoint.x < this.x + this.width && this.y <= targetPoint.y) {
        return targetPoint.y < this.y + this.height;
      } else {
        return false;
      }
    };

    XNARectangle.prototype.intersects = function(targetRectangle) {
      if (targetRectangle.x < this.x + this.width && this.x < targetRectangle.x + targetRectangle.width && targetRectangle.y < this.y + this.height) {
        return this.y < targetRectangle.y + targetRectangle.height;
      } else {
        return false;
      }
    };

    XNARectangle.prototype.getBottomCenter = function() {
      return new Point(parseInt(this.x + (this.width / 2)), this.bottom());
    };

    XNARectangle.prototype.getIntersectionDepth = function(rectB) {
      var centerA, centerB, depthX, depthY, distanceX, distanceY, halfHeightA, halfHeightB, halfWidthA, halfWidthB, minDistanceX, minDistanceY, rectA;
      rectA = this;
      halfWidthA = rectA.width / 2.0;
      halfHeightA = rectA.height / 2.0;
      halfWidthB = rectB.width / 2.0;
      halfHeightB = rectB.height / 2.0;
      centerA = new Point(rectA.left() + halfWidthA, rectA.top() + halfHeightA);
      centerB = new Point(rectB.left() + halfWidthB, rectB.top() + halfHeightB);
      distanceX = centerA.x - centerB.x;
      distanceY = centerA.y - centerB.y;
      minDistanceX = halfWidthA + halfWidthB;
      minDistanceY = halfHeightA + halfHeightB;
      depthX = (distanceX > 0 ? minDistanceX - distanceX : -minDistanceX - distanceX);
      depthY = (distanceY > 0 ? minDistanceY - distanceY : -minDistanceY - distanceY);
      if (Math.abs(distanceX) >= minDistanceX) {
        depthX = 0;
      }
      if (Math.abs(distanceY) >= minDistanceY) {
        depthY = 0;
      }
      console.log(depthX, depthY, minDistanceX);
      return new Point(depthX, depthY);
    };

    window.XNARectangle = XNARectangle;

    return XNARectangle;

  })(Rectangle);

}).call(this);
