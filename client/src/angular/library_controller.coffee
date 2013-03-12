LibraryCtrl = ($scope) ->

  $scope.library_name = 'Library'

  $scope.definitions = () ->
    return [] unless window.Game?.Library?
    window.Game.Library.definitions


  $scope.cssForSprite = (actor, x = 0, y = 0) ->
    x = x * Tile.WIDTH
    y = y * Tile.HEIGHT
    "background-image:url(#{actor.spritesheet.data}); width:#{Tile.WIDTH}px; height:#{Tile.HEIGHT}px; background-position:-#{x}px -#{y}px;"

  $scope.selected_definition = () ->
    $scope.Manager.level.selectedDefinition

  $scope.selected_animations = () ->
    return [] unless $scope.Manager && $scope.Manager.level.selectedDefinition
    $scope.Manager.level.selectedDefinition.spritesheet.animations

  $scope.edit_animation = (key, coords) ->
    $scope.$root.$broadcast('edit_animation', {actor_definition: $scope.selected_definition(), coords:coords})


window.LibraryCtrl = LibraryCtrl