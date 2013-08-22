@AppCtrl = ($scope, $location, Users, Stages, Auth, $http) ->

  Auth.withUser (error, user) ->
    if error || !user
        alert('You need to log in!')

    $scope.$apply() unless $scope.$$phase

    # find canvas and load images, wait for last image to load
    stagePane1 = new GameStage($("#platformerCanvasPane1")[0])
    stagePane2 = new GameStage($("#platformerCanvasPane2")[0])
    renderingStage = new Stage($("#renderingCanvas")[0])

    $(document).on 'mousedown', (e) ->
      window.mouseIsDown = true
      true #continue propogation

    $(document).on 'mouseup', (e) ->
      window.mouseIsDown = false
      true #continue propogation

    window.Game = new GameManager(stagePane1, stagePane2, renderingStage)
    window.rootScope = angular.element('body').scope()

    path = window.location.href.split('#')[1]
    path = path.split('/')
    window.Game.load(path[path.length-2], path[path.length-1])


@AppCtrl.$inject = ['$scope', '$location', 'Users', 'Stages', 'Auth', '$http']
