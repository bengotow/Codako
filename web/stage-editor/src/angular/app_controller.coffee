@AppCtrl = ($scope, $location, Users, Stages, Worlds, Auth, $http) ->

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
    window.world_id = $scope.world_id = parts[1]
    window.stage_id = $scope.stage_id = parts[2]

    window.view_only = (window.location.href.indexOf('stage-viewer') != -1)

    if !$scope.world_id
      window.location.href = "/"

    else if !$scope.stage_id
      Stages.index {world_id: $scope.world_id}, (stages) ->
        if !stages || stages.length == 0
          alert('Sorry, the world could not be found or is not public.')
          window.location.href = "/"
          return
        window.location.href = "#{window.location.href.split('#')[0]}#/#{$scope.world_id}/#{stages[0]._id}"

    else
      window.Game.load($scope.world_id, $scope.stage_id)



@AppCtrl.$inject = ['$scope', '$location', 'Users', 'Stages', 'Worlds', 'Auth', '$http']
