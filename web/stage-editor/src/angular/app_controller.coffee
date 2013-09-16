@AppCtrl = ($scope, $location, Users, Stages, Auth, $http) ->

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
    window.onunload = (e) ->
      window.Game.save({thumbnail: true, async: false})

    path = window.location.href.split('#')[1]
    parts = path.split('/')
    window.stage_id = parts[parts.length-1]
    window.world_id = parts[parts.length-2]
    window.view_only = (window.location.href.indexOf('stage-viewer') != -1)

    if !window.stage_id || !window.world_id
      window.location.href = "/"

    window.Game.load(window.world_id, window.stage_id)



@AppCtrl.$inject = ['$scope', '$location', 'Users', 'Stages', 'Auth', '$http']
