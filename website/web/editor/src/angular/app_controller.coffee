@AppCtrl = ($scope, $location, $routeParams, Users, Stages, Auth, $http) ->

  Auth.withUser (error, user) ->
      $scope.$apply() unless $scope.$$phase

      # find canvas and load images, wait for last image to load
      stagePane1 = new GameStage($("#platformerCanvasPane1")[0])
      stagePane2 = new GameStage($("#platformerCanvasPane2")[0])
      renderingStage = new Stage($("#renderingCanvas")[0])

      window.Game.load($routeParams.world_id, $routeParams.stage_id)

      $(document).mousedown (e) ->
        window.mouseIsDown = true

      $(document).mouseup (e) ->
        window.mouseIsDown = false

      window.Game = new GameManager(stagePane1, stagePane2, renderingStage)
      window.rootScope = angular.element('body').scope()


@AppCtrl.$inject = ['$scope', '$location', '$routeParams', 'Users', 'Stages', 'Auth', '$http']
