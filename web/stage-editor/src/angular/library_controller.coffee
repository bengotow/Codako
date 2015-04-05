LibraryCtrl = ($scope) ->

  $scope.library_name = 'Library'
  $scope.selected_appearance = null

  # -- Definitions -- #

  $scope.definitions = ->
    return [] unless window.Game?.library?
    window.Game.library.definitions


  $scope.add_definition = ->
    window.Game.library.createActorDefinition (err, actor) ->
      window.Game.selectDefinition(actor)
      $scope.$apply()
      $scope.$root.$broadcast('edit_appearance', {actor_definition: actor, identifier: 'idle'})


  $scope.select_definition = (def) ->
    if window.Game.tool == 'delete'
      if confirm('Are you sure you want to remove this actor? When you delete something from your library, all copies of it are deleted.')
        definitions = $scope.definitions()
        delete definitions[def._id]
        window.Game.mainStage.removeActorsMatchingDescriptor({definition_id: def._id})
        window.Game.stagePane1.removeActorsMatchingDescriptor({definition_id: def._id})
        window.Game.save()

      window.Game.resetToolAfterAction()
    else
      window.Game.selectActor(null)
      window.Game.selectedDefinition = def


  $scope.selected_definition = ->
    window.Game?.selectedDefinition


  $scope.save_definition = (definition = null) ->
    definition = $scope.selected_definition() unless definition
    definition.save()


  # -- Appearances -- #

  $scope.appearances = ->
    return [] unless window.Game && window.Game.selectedDefinition
    window.Game.selectedDefinition.spritesheet.animations

  $scope.add_appearance = ->
    definition = $scope.selected_definition()
    identifier = definition.addAppearance()
    $scope.$root.$broadcast('edit_appearance', {actor_definition: definition, identifier: identifier})

  $scope.select_appearance = (id) ->
    if window.Game.tool == 'delete'
      if confirm('Are you sure you want to delete this appearance?')
        $scope.selected_definition().deleteAppearance(id)
        $scope.selected_definition().save()
    if window.Game.tool == 'paint'
      $scope.edit_appearance(id)

    window.Game.resetToolAfterAction()


  $scope.edit_appearance = (id) ->
    $scope.$root.$broadcast('edit_appearance', {actor_definition: $scope.selected_definition(), identifier: id})

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
    return 'active' if definition == window.Game.selectedDefinition
    return ''

  $scope.class_for_appearance = (identifer) ->
    return 'active' if identifer == $scope.selected_appearance
    return ''

  $scope.css_for_sprite_frame = (definition, index = 0) ->
    [x,y,w,h] = definition.xywhForSpritesheetFrame(index)
    "background-image:url(#{definition.spritesheet.data}); background-repeat:no-repeat; width:#{w}px; height:#{h}px; background-position:-#{x}px -#{y}px;"



window.LibraryCtrl = LibraryCtrl