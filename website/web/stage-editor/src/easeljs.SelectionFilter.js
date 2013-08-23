
this.createjs = this.createjs||{};

(function() {

/**
 * Applies a color transform to DisplayObjects.
 *
 * <h4>Example</h4>
 * This example draws a red circle, and then transforms it to Blue. This is accomplished by multiplying all the channels
 * to 0 (except alpha, which is set to 1), and then adding 255 to the blue channel.
 *
 *      var shape = new createjs.Shape().set({x:100,y:100});
 *      shape.graphics.beginFill("#ff0000").drawCircle(0,0,50);
 *
 *      shape.filters = [
 *          new createjs.ColorFilter(0,0,0,1, 0,0,255,0)
 *      ];
 *      shape.cache(-50, -50, 100, 100);
 *
 * See {{#crossLink "Filter"}}{{/crossLink}} for an more information on applying filters.
 * @class ColorFilter
 * @constructor
 * @extends Filter
 * @param {Number} [redMultiplier=1] The amount to multiply against the red channel. This is a range between 0 and 1.
 * @param {Number} [greenMultiplier=1] The amount to multiply against the green channel. This is a range between 0 and 1.
 * @param {Number} [blueMultiplier=1] The amount to multiply against the blue channel. This is a range between 0 and 1.
 * @param {Number} [alphaMultiplier=1] The amount to multiply against the alpha channel. This is a range between 0 and 1.
 * @param {Number} [redOffset=0] The amount to add to the red channel after it has been multiplied. This is a range
 * between -255 and 255.
 * @param {Number} [greenOffset=0] The amount to add to the green channel after it has been multiplied. This is a range
  * between -255 and 255.
 * @param {Number} [blueOffset=0] The amount to add to the blue channel after it has been multiplied. This is a range
  * between -255 and 255.
 * @param {Number} [alphaOffset=0] The amount to add to the alpha channel after it has been multiplied. This is a range
  * between -255 and 255.
 **/
var SelectionFilter = function(borderWidth) {
  this.initialize(borderWidth);
}
var p = SelectionFilter.prototype = new createjs.Filter();

	/**
	 * Width fo the border applied by this filter
	 * @property borderWidth
	 * @type Number
	 **/
	p.borderWidth = 0;

// constructor:
	/**
	 * Initialization method.
	 * @method initialize
	 * @protected
	 **/
	p.initialize = function(borderWidth) {
		this.borderWidth = borderWidth != null ? borderWidth : 1;
	}

// public methods:
	/**
	 * Returns a rectangle with values indicating the margins required to draw the filter.
	 * For example, a filter that will extend the drawing area 4 pixels to the left, and 7 pixels to the right
	 * (but no pixels up or down) would return a rectangle with (x=-4, y=0, width=11, height=0).
	 * @method getBounds
	 * @return {Rectangle} a rectangle object indicating the margins required to draw the filter.
	 **/
	p.getBounds = function() {
		return new createjs.Rectangle(this.borderWidth,this.borderWidth,this.borderWidth*2,this.borderWidth*2);
	}

	p.applyFilter = function(ctx, x, y, width, height, targetCtx, targetX, targetY) {
		targetCtx = targetCtx || ctx;
		if (targetX == null) { targetX = x; }
		if (targetY == null) { targetY = y; }

		try {
			var imageData = ctx.getImageData(x, y, width, height);
		} catch(e) {
			console.log(e);
			return false;
		}

		for (var iteration = 0; iteration < this.borderWidth; iteration ++) {
			var data = imageData.data;
			var l = data.length;
			var edge = [];
			for (var x=0; x < width; x ++) {
				for (var y=0; y < height; y ++) {
					var i = 4 * ((y * width) + x);
					if (data[4 * (((y) * width) + x) + 3] == 0) {
						if ((data[4 * (((y-1) * width) + x) + 3] > 0) ||
						 	(data[4 * (((y+1) * width) + x) + 3] > 0) ||
						 	(data[4 * ((y * width) + (x+1)) + 3] > 0) ||
							(data[4 * ((y * width) + (x-1)) + 3] > 0)) {
							edge.push({x:x, y:y})

						} else if ((iteration == this.borderWidth - 1) &&
								((data[4 * (((y-1) * width) + (x-1)) + 3] > 0) ||
						 		 (data[4 * (((y-1) * width) + (x+1)) + 3] > 0) ||
						 		 (data[4 * (((y+1) * width) + (x-1)) + 3] > 0) ||
						 		 (data[4 * (((y+1) * width) + (x+1)) + 3] > 0))) {
							edge.push({x:x, y:y, alias: true})
						}
					} else {
						for (var o=0; o<3; o++)
							data[i+o] += 15;
					}
				}
			}

			for (var i=0; i < edge.length; i++) {
				var x = edge[i].x;
				var y = edge[i].y;
				var b = 4 * ((y * width) + x);
				for (var o=0; o<3; o++)
					data[b+o] = 255;
				if (edge.alias)
					data[b+3] = 50;
				else
					data[b+3] = 150 + 50 / (iteration + 1);

			}
		}

		imageData.data = data;
		targetCtx.putImageData(imageData, targetX, targetY);
		return true;
	}

	p.toString = function() {
		return "[SelectionFilter]";
	}

	/**
	 * Returns a clone of this SelectionFilter instance.
	 * @method clone
	 * @return {SelectionFilter} A clone of the current SelectionFilter instance.
	 **/
	p.clone = function() {
		return new SelectionFilter(this.borderWidth);
	}

	createjs.SelectionFilter = SelectionFilter;

}());