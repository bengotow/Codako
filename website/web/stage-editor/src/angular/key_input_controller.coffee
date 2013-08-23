KeyInputCtrl = ($scope) ->

  $scope.key_code = false
  $scope.visible = false
  $scope.done_callback = null

  $scope.$root.$on 'edit_key', (msg, args) ->
    $scope.key_code = args.key_code
    $scope.visible = true
    $scope.done_callback = args.completion_callback
    $('#keyInputModal').modal({show:true})
    $scope.redraw()


  $('body').keydown (event) ->
    return true unless $scope.visible
    $scope.key_code = event.keyCode
    $scope.$apply()
    $scope.redraw()

    event.preventDefault()


  $scope.redraw = () ->
    drawingCanvas = document.getElementById('keyInputCanvas')
    if (drawingCanvas.getContext)
      context = drawingCanvas.getContext('2d')

      map = [
        ['`','1','2','3','4','5','6','7','8','9','0','-','+', {length:1.65, value: '—'}],
        [{length:1.65,value: 9},'Q','W','E','R','T','Y','U','I','O','P','[',']','\\']
        [{length:1.87,value: '—'},'A','S','D','F','G','H','J','K','L',';', ',', {length:1.85,value: 13}]
        [{length:2.45,value: '—'},'Z','X','C','V','B','N','M','<','>','?',{length:2.45,value: '—'}]
        ['—','—','—',{length:1.6,value: '—'}, {length: 5, value: 32}, {length:1.6,value: '—'},'—',{length: 1, value: [null, 37]},{length: 1, value: [38, 40]},{length: 1, value: [null, 39]}]
      ]

      x = 0
      y = 0
      u = drawingCanvas.width / 15.9

      for row in map
        for key in row
          w = Math.round(u * key.length)
          value = key.value || key
          value = [value] unless value instanceof Array
          h = Math.round((u - 3 * (value.length - 1)) / value.length)
          yy = 0
          for v in value
            if v == '—'
              context.fillStyle = '#eee'
            else if $scope.key_code == v || String.fromEventKeyCode($scope.key_code) == v
              context.fillStyle = 'blue'
            else
              context.fillStyle = '#ccc'
            context.fillRect(x,y + yy,w,h) if v != null
            yy += h + 3

          x += w + 3
        y += u + 3
        x = 0

    return false


  $scope.html_for_key_code = () ->
    if $scope.key_code == 37
      '<i class="icon-arrow-left"></i>'
    else if $scope.key_code == 38
      '<i class="icon-arrow-up"></i>'
    else if $scope.key_code == 39
      '<i class="icon-arrow-right"></i>'
    else if $scope.key_code == 40
      '<i class="icon-arrow-down"></i>'
    else
      String.fromEventKeyCode($scope.key_code)


  $scope.cancel = () ->
    $scope.visible = false

  $scope.done = () ->
    $scope.visible = false
    $scope.done_callback($scope.key_code) if $scope.done_callback


window.KeyInputCtrl = KeyInputCtrl