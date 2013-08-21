(function() {
  var LibraryCtrl;

  LibraryCtrl = function($scope) {
    $scope.library_name = 'Library';
    $scope.selected_appearance = null;
    $scope.definitions = function() {
      var _ref;
      if (((_ref = window.Game) != null ? _ref.library : void 0) == null) {
        return [];
      }
      return window.Game.library.definitions;
    };
    $scope.add_definition = function() {
      var actor;
      actor = new ActorDefinition();
      return window.Game.library.addActorDefinition(actor, function() {
        window.Game.selectDefinition(actor);
        $scope.$apply();
        return $scope.$root.$broadcast('edit_appearance', {
          actor_definition: actor,
          identifier: 'idle'
        });
      });
    };
    $scope.select_definition = function(def) {
      var definitions;
      if (window.Game.tool === 'delete') {
        if (confirm('Are you sure you want to remove this actor? When you delete something from your library, all copies of it are deleted.')) {
          definitions = $scope.definitions();
          delete definitions[def.identifier];
          window.Game.mainStage.removeActorsMatchingDescriptor({
            identifier: def.identifier
          });
          window.Game.stagePane1.removeActorsMatchingDescriptor({
            identifier: def.identifier
          });
          window.Game.save();
        }
        return window.Game.resetToolAfterAction();
      } else {
        window.Game.selectActor(null);
        return window.Game.selectedDefinition = def;
      }
    };
    $scope.selected_definition = function() {
      var _ref;
      return (_ref = window.Game) != null ? _ref.selectedDefinition : void 0;
    };
    $scope.save_definition = function(definition) {
      if (definition == null) {
        definition = null;
      }
      if (!definition) {
        definition = $scope.selected_definition();
      }
      return definition.save();
    };
    $scope.appearances = function() {
      if (!(window.Game && window.Game.selectedDefinition)) {
        return [];
      }
      return window.Game.selectedDefinition.spritesheet.animations;
    };
    $scope.add_appearance = function() {
      var definition, identifier;
      definition = $scope.selected_definition();
      identifier = definition.addAppearance();
      return $scope.$root.$broadcast('edit_appearance', {
        actor_definition: definition,
        identifier: identifier
      });
    };
    $scope.select_appearance = function(id) {
      if (window.Game.tool === 'delete') {
        if (confirm('Are you sure you want to delete this appearance?')) {
          $scope.selected_definition().deleteAppearance(id);
          $scope.selected_definition().save();
        }
      }
      if (window.Game.tool === 'paint') {
        $scope.edit_appearance(id);
      }
      return window.Game.resetToolAfterAction();
    };
    $scope.edit_appearance = function(id) {
      return $scope.$root.$broadcast('edit_appearance', {
        actor_definition: $scope.selected_definition(),
        identifier: id
      });
    };
    $scope.save_appearance_name = function(event) {
      var definition, identifier, name;
      definition = $scope.selected_definition();
      identifier = $(event.target).data('identifier');
      name = $(event.target).val();
      definition.renameAppearance(identifier, name);
      return definition.save();
    };
    $scope.name_for_appearance = function(name) {
      return $scope.selected_definition().nameForAppearance(name);
    };
    $scope.class_for_definition = function(definition) {
      if (definition === window.Game.selectedDefinition) {
        return 'active';
      }
      return '';
    };
    $scope.class_for_appearance = function(identifer) {
      if (identifer === $scope.selected_appearance) {
        return 'active';
      }
      return '';
    };
    return $scope.css_for_sprite_frame = function(definition, index) {
      var h, w, x, y, _ref;
      if (index == null) {
        index = 0;
      }
      _ref = definition.xywhForSpritesheetFrame(index), x = _ref[0], y = _ref[1], w = _ref[2], h = _ref[3];
      return "background-image:url(" + definition.spritesheet.data + "); background-repeat:no-repeat; width:" + w + "px; height:" + h + "px; background-position:-" + x + "px -" + y + "px;";
    };
  };

  window.LibraryCtrl = LibraryCtrl;

}).call(this);
