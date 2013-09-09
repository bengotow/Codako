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