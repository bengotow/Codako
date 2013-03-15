LibraryCtrl = ($scope) ->

  $scope.library_name = 'Library'
  $scope.selected_appearance = null
  $scope.trash = $('#trashcan')
  $scope.trash[0].ondrop = (e, dragEl) ->
    setTimeout () ->
      identifier = $(dragEl.draggable).data('identifier')
      if identifier[0..4] == 'actor'
        if confirm('Are you sure you want to remove this actor? When you delete something from your library, all copies of it are deleted.')
          definitions = $scope.definitions()
          identifier = identifier[6..-1]

          window.Game.Manager.level.removeActorsMatchingDescriptor({identifier: identifier})
          window.Game.Manager.level.save()
          delete definitions[identifier]

      else if identifier[0..9] == 'appearance'
        if confirm('Are you sure you want to delete this appearance?')
          $scope.selected_definition.deleteAppearance(identifier[11..-1])
          $scope.selected_definition.save()
      $scope.$apply()
    ,250


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

  $scope.appearances = () ->
    return [] unless $scope.Manager && $scope.Manager.level.selectedDefinition
    $scope.Manager.level.selectedDefinition.spritesheet.animations

  $scope.add_appearance = () ->
    definition = $scope.selected_definition()
    identifier = definition.addAppearance()
    $scope.$root.$broadcast('edit_appearance', {actor_definition: definition, identifier: identifier})

  $scope.select_appearance = (identifier) ->
    $scope.selected_appearance = identifier

  $scope.edit_appearance = (identifier) ->
    $scope.$root.$broadcast('edit_appearance', {actor_definition: $scope.selected_definition(), identifier: identifier})

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

  $scope.class_for_appearance = (identifer) ->
    return 'active' if identifer == $scope.selected_appearance
    return ''

  $scope.css_for_sprite_frame = (definition, index = 0) ->
    [x,y,w,h] = definition.xywhForSpritesheetFrame(index)
    "background-image:url(#{definition.spritesheet.data}); background-repeat:no-repeat; width:#{w}px; height:#{h}px; background-position:-#{x}px -#{y}px;"



window.LibraryCtrl = LibraryCtrl