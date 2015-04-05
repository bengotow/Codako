  (function( $ ) {
    $.fn.highlighter = function(action, options) {
      this.each(function() {
        if ( action === "show") {
          var canvas = $("<canvas style='position:absolute; z-index:3000; pointer-events:none;'></canvas>");
          var canvasEl = canvas[0];
          $('body').append(canvas);
          this.highlighterCanvas = canvas;

          if (options) {
            canvas.offset(options.offset);
            canvasEl.width = options.width;
            canvasEl.height = options.height;

          } else {
            marginX = 55;
            marginY = 40;
            offset = $(this).offset();
            offset.left -= marginX;
            offset.top -= marginY;
            canvas.offset(offset);
            canvasEl.width = $(this).outerWidth() + marginX * 2;
            canvasEl.height = $(this).outerHeight() + marginY * 2;
          }

          fraction = 0;
          seed = Math.random()

          canvas.render = function() {
            var context = canvasEl.getContext('2d');
            var deg = 0;
            var cx = canvasEl.width / 2 - 5;
            var cy = canvasEl.height / 2;
            var rx = cx - 25;
            var ry = cy - 25;

            context.clearRect(0,0, canvasEl.width, canvasEl.height);
            context.strokeStyle = "red";
            context.beginPath();

            var degStart = -150 + seed * 20;
            var degEnd = (degStart + 410 * Math.sin(fraction * Math.PI / 2));
            var degStep = 1 / (Math.max(rx,ry) / 50)
            var taper = 0;

            for (deg = degStart; deg < degEnd; deg += degStep) {
              if (deg > degEnd - 15)
                taper += 0.05;

              context.moveTo(cx + Math.cos(deg * Math.PI/180.0) * (rx - 8 + taper), cy + Math.sin(deg * Math.PI/180.0) * (ry - 8 + taper))
              context.lineTo(cx + Math.cos((deg + 4) * Math.PI/180.0) * (rx - taper), cy + Math.sin((deg + 4) * Math.PI/180.0) * (ry-taper))

              if (deg > 200) {
                ry += 0.07 + (-0.02 + (1-seed) * 0.04);
                rx += 0.1 + (-0.04 + seed * 0.08);
              } else if (deg > 80) {
                rx -= 0.05 + (-0.04 + (1-seed) * 0.08);
              }

            }
            context.closePath();
            context.stroke();

            fraction += 0.007;
            if (fraction < 1)
              setTimeout(canvas.render, 1/20.0);
          }

          canvas.render();

        }
        if ( action === "erase" ) {
          if (this.highlighterCanvas == null || this.highlighterCanvas == undefined)
            return;
          this.highlighterCanvas.animate({
            opacity: 0.0
          }, 500, function() {
            if (this.highlighterCanvas)
              this.highlighterCanvas.remove()
          });
        }
      });
    };
  }( jQuery ));


(function( $ ) {
  $.fn.arrow = function(action, target, options) {
    this.each(function() {
      if ( action === "show") {
        var canvas = $("<canvas style='position:absolute; z-index:3000; pointer-events:none;'></canvas>");
        var canvasEl = canvas[0];
        $('body').append(canvas);
        this.arrowCanvas = canvas;

        canvas.offset({left: 0, top: 0});
        canvasEl.width = window.innerWidth;
        canvasEl.height = window.innerHeight;

        fraction = 0;

        var start = $(this).offset();
        start.left += $(this).width() / 2;
        start.top += $(this).height() / 2;
        var end = target.offset();
        end.left += target.width() / 2;
        end.top += target.height() / 2;

        canvas.render = function() {
          var context = canvasEl.getContext('2d');

          context.clearRect(0,0, canvasEl.width, canvasEl.height);
          context.lineWidth = 12;
          context.lineCap="round";
          context.strokeStyle = "red";

          var dx = (end.left - start.left) * fraction;
          var dy = (end.top - start.top) * fraction;

          for (var x = 0; x <= 10; x ++) {
            var f = x / 10;
            context.lineWidth = 5 + x * 0.8;
            context.beginPath();
            context.moveTo(start.left + dx * f, start.top + dy * f);
            context.lineTo(start.left + dx, start.top + dy);
            context.stroke();
          }

          context.beginPath();
          context.moveTo(start.left + dx, start.top + dy);
          context.lineTo(start.left + dx - 26, start.top + dy + 20);
          context.moveTo(start.left + dx, start.top + dy);
          context.lineTo(start.left + dx + 26, start.top + dy + 20);
          context.stroke();

          fraction += 0.007;
          if (fraction < 1)
            setTimeout(canvas.render, 1/20.0);
        }

        canvas.render();

      }
      if ( action === "erase" ) {
        if (this.arrowCanvas == null || this.arrowCanvas == undefined)
          return;
        this.arrowCanvas.animate({
          opacity: 0.0
        }, 500, function() {
          if (this.arrowCanvas)
            this.arrowCanvas.remove()
        });
      }
    });
  };
}( jQuery ));