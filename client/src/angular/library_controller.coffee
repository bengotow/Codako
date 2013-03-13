LibraryCtrl = ($scope) ->

  $scope.library_name = 'Library'

  # -- Definitions -- #

  $scope.definitions = () ->
    return [] unless window.Game?.Library?
    window.Game.Library.definitions

  $scope.add_definition = () ->
    actor = new ActorDefinition()
    window.Game.Library.addActorDefinition(actor)

  $scope.select_definition = (def) ->
    $scope.Manager.level.selectedDefinition = def

  $scope.selected_definition = () ->
    $scope.Manager.level.selectedDefinition

  $scope.save_definition = (definition = null) ->
    definition = $scope.selected_definition() unless definition
    definition.save()


  # -- Appearances -- #

  $scope.selected_appearances = () ->
    return [] unless $scope.Manager && $scope.Manager.level.selectedDefinition
    $scope.Manager.level.selectedDefinition.spritesheet.animations

  $scope.edit_appearance = (identifier) ->
    $scope.$root.$broadcast('edit_appearance', {actor_definition: $scope.selected_definition(), identifier: identifier})

  $scope.add_appearance = () ->
    definition = $scope.selected_definition()
    identifier = definition.addAppearance()
    $scope.$root.$broadcast('edit_appearance', {actor_definition: definition, identifier: identifier})

  $scope.save_appearance_name = (event) ->
    definition = $scope.selected_definition()
    identifier = $(event.target).data('identifier')
    name = $(event.target).val()
    definition.renameAppearance(identifier, name)
    definition.save()


  # -- Convenience Helpers -- #

  $scope.name_for_appearance = (name) ->
    $scope.selected_definition().nameForAppearance(name)

  $scope.class_for_definition = (definition) ->
    return 'active' if definition == $scope.Manager.level.selectedDefinition
    return ''

  $scope.css_for_sprite_frame = (definition, index = 0) ->
    [x,y,w,h] = definition.xywhForSpritesheetFrame(index)
    console.log x,y,w,h
    "background-image:url(#{definition.spritesheet.data}); background-repeat:no-repeat; width:#{w}px; height:#{h}px; background-position:-#{x}px -#{y}px;"



window.LibraryCtrl = LibraryCtrl