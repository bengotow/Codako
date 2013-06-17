ComposeRuleCtrl = ($scope) ->

  $scope.actor = null
  $scope.rule = {}
  $scope.beforeStage = new Stage($('#beforeCanvas')[0])
  $scope.beforeActors = []

  $scope.afterStage = new Stage($('#afterCanvas')[0])
  $scope.afterActors = []

  $scope.included = []
  $scope.extent = null
  $scope.ruleExtent = null

  # $scope.$root.$on 'compose_rule', (msg, args) ->
  #   w = $('#beforeCanvas').attr('width') / Tile.WIDTH
  #   h = $('#beforeCanvas').attr('height') / Tile.HEIGHT

  #   $scope.extent = {left: -(w-1) / 2, top: -(h-1) / 2, right: (w-1) / 2, bottom: (w-1) / 2}

  #   $scope.actor = args.actor
  #   $scope.rule = args.rule
  #   $('#composeRuleModal').modal({show:true})
  #   $scope.setupStages()

  #   Ticker.addListener($scope)
  #   Ticker.useRAF = false
  #   Ticker.setFPS(60)


  $scope.tick = () ->
    $scope.afterStage.update()
    $scope.beforeStage.update()

  $scope.setupStages = () ->
    ruleExtent = {left: 10000, top: 10000, right: 0, bottom: 0}

    for stage in [$scope.beforeStage, $scope.afterStage]
      background = new Bitmap(window.Game.content.imageNamed('Layer0_0'))
      stage.addChild(background)

    # read the scenario definition
    for block in $scope.rule.scenario
      [x,y] = block.coord.split(',')
      $scope.included.push("#{x},#{y}")
      ruleExtent.left = Math.min(x, ruleExtent.left)
      ruleExtent.right = Math.max(x, ruleExtent.right)
      ruleExtent.top = Math.min(y, ruleExtent.top)
      ruleExtent.bottom = Math.max(y, ruleExtent.bottom)

      continue unless block.descriptors
      for descriptor in block.descriptors
        $scope.beforeStage.addChild($scope.actorFromScenarioDescriptor(descriptor, x, y))
        $scope.afterStage.addChild($scope.actorFromScenarioDescriptor(descriptor, x, y))

    # add the dark gray square on top of each unincluded square
    for stage in [$scope.beforeStage, $scope.afterStage]
      for x in [$scope.extent.left..$scope.extent.right]
        for y in [$scope.extent.top..$scope.extent.bottom]
          sprite = null
          sprite ||= new SquareMaskSprite('masked') if (x < ruleExtent.left || x > ruleExtent.right) || (y < ruleExtent.top || y > ruleExtent.bottom)
          sprite ||= new SquareMaskSprite('masked_checkered') if $scope.included.indexOf("#{x},#{y}") == -1
          if sprite
            sprite.x = (x-$scope.extent.left) * Tile.WIDTH
            sprite.y = (y-$scope.extent.top) * Tile.HEIGHT
            stage.addChild(sprite)

      stage.update()

    # add the handles to the e


  $scope.actorFromScenarioDescriptor = (descriptor, x, y) ->
    actor = window.Game.library.instantiateActorFromDescriptor(descriptor)
    actor.setWorldPos(x - $scope.extent.left, y - $scope.extent.top)
    actor.tick()
    actor

window.ComposeRuleCtrl = ComposeRuleCtrl