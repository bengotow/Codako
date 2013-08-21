(function() {
  var RulesCtrl;

  RulesCtrl = function($scope) {
    window.rulesScope = $scope;
    $scope.structs_lookup_table = null;
    $scope.flow_types = {
      'Do First Match': 'first',
      'Do All & Continue': 'all',
      'Randomize & Do First': 'random'
    };
    $scope.definition_name = function() {
      if (!(window.Game && window.Game.selectedDefinition)) {
        return void 0;
      }
      return window.Game.selectedDefinition.name;
    };
    $scope.rules = function() {
      if (!(window.Game && window.Game.selectedDefinition)) {
        return void 0;
      }
      return window.Game.selectedDefinition.rules;
    };
    $scope.add_rule = function() {
      return window.Game.editNewRuleForActor(window.Game.selectedActor);
    };
    $scope.rule_clicked = function(rule) {
      if (window.Game.tool === 'delete') {
        if (rule.event === 'idle') {
          alert('Sorry, you can\'t remove the idle case!');
        } else if (confirm('Are you sure you want to delete this rule? You can\'t undo this action.')) {
          window.Game.selectedDefinition.removeRule(rule);
        }
      }
      return window.Game.resetToolAfterAction();
    };
    $scope.rule_dbl_clicked = function(rule) {
      return window.Game.editRule(rule, window.Game.selectedActor);
    };
    $scope.add_rule_group_event = function(type) {
      var code;
      if (type === 'key') {
        code = 'A';
        return window.Game.selectedDefinition.addEventGroup({
          event: type,
          code: code
        });
      } else {
        return window.Game.selectedDefinition.addEventGroup({
          event: type
        });
      }
    };
    $scope.add_rule_group_flow = function() {
      return window.Game.selectedDefinition.addFlowGroup();
    };
    $scope.save_rules = function() {
      return window.Game.selectedDefinition.save();
    };
    $scope.scenario_before_url = function(rule) {
      var cache, _name;
      cache = window.Game.selectedDefinition.ruleRenderCache;
      cache[_name = "" + rule._id + "-before"] || (cache[_name] = window.Game.renderRule(rule));
      return cache["" + rule._id + "-before"] || "";
    };
    $scope.scenario_after_url = function(rule) {
      var cache, _name;
      cache = window.Game.selectedDefinition.ruleRenderCache;
      cache[_name = "" + rule._id + "-after"] || (cache[_name] = window.Game.renderRule(rule, true));
      return cache["" + rule._id + "-after"] || "";
    };
    $scope.toggle_disclosed = function(struct) {
      if (struct.disclosed) {
        return delete struct.disclosed;
      } else {
        return struct.disclosed = 'disclosed';
      }
    };
    $scope.name_for_key = function(code) {
      if (code === 32) {
        return "Space Bar";
      }
      if (code === 38) {
        return "Up Arrow";
      }
      if (code === 37) {
        return "Left Arrow";
      }
      if (code === 39) {
        return "Right Arrow";
      }
      return String.fromCharCode(code);
    };
    $scope.name_for_event_group = function(struct) {
      if (struct.event === 'key') {
        return "When the " + ($scope.name_for_key(struct.code)) + " Key is Pressed";
      } else if (struct.event === 'click') {
        return "When I'm Clicked";
      } else {
        return "When I'm Idle";
      }
    };
    $scope.name_for_flow_group = function(struct) {
      return "Flow Group";
    };
    $scope.sortable_attributes_for_rules_root = function() {
      var rules;
      rules = $scope.rules();
      if (!rules) {
        return void 0;
      }
      if (rules.length > 0 && rules[0].type === 'group-event') {
        return "disabled";
      } else {
        return {
          'connectWith': '.rules-list'
        };
      }
    };
    $scope.sortable_change_start = function() {
      var struct, _i, _len, _ref, _results;
      $scope.structs_lookup_table = {};
      $scope.structs_lookup_table['base'] = {
        rules: $scope.rules()
      };
      _ref = $scope.rules();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        struct = _ref[_i];
        _results.push($scope.populate_structs_lookup_table(struct));
      }
      return _results;
    };
    $scope.sortable_contents_changed = function(event, ui) {
      var key, struct, _ref;
      _ref = $scope.structs_lookup_table;
      for (key in _ref) {
        struct = _ref[key];
        if (struct.rules) {
          $scope.recompute_struct_contents(key);
        }
      }
      return window.Game.selectedDefinition.save();
    };
    $scope.recompute_struct_contents = function(container_id) {
      var child, child_els, child_ids, child_struct, container, container_el, id, root_index, _i, _j, _len, _len1, _results;
      container_el = $("[data-id='" + container_id + "']");
      child_els = container_el.find('ul').first().children('[data-id]');
      child_ids = [];
      for (_i = 0, _len = child_els.length; _i < _len; _i++) {
        child = child_els[_i];
        child_ids.push($(child).data('id'));
      }
      container = $scope.structs_lookup_table[container_id];
      container.rules.length = 0;
      _results = [];
      for (_j = 0, _len1 = child_ids.length; _j < _len1; _j++) {
        id = child_ids[_j];
        child_struct = $scope.structs_lookup_table[id];
        root_index = $scope.rules().indexOf(child_struct);
        if (root_index >= 0) {
          $scope.rules().splice(root_index, 1);
        }
        _results.push(container.rules.push(child_struct));
      }
      return _results;
    };
    $scope.populate_structs_lookup_table = function(struct) {
      var rule, _i, _len, _ref, _results;
      $scope.structs_lookup_table[struct._id] = struct;
      if (struct.rules) {
        _ref = struct.rules;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          rule = _ref[_i];
          _results.push($scope.populate_structs_lookup_table(rule));
        }
        return _results;
      }
    };
    $scope.circle_for_rule = function(struct) {
      var actor, _ref;
      actor = (_ref = window.Game) != null ? _ref.selectedActor : void 0;
      if (!(struct && actor)) {
        return 'circle';
      }
      if (actor.applied[struct._id]) {
        return 'circle true';
      }
      return 'circle false';
    };
    return $scope.actions_for_rule = function(rule) {
      var actions;
      return actions = [];
    };
  };

  window.RulesCtrl = RulesCtrl;

}).call(this);
