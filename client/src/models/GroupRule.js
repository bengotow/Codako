(function() {
  var EventGroupRule, FlowGroupRule, GroupRule,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  GroupRule = (function() {

    function GroupRule(json) {
      var key, value;
      if (json == null) {
        json = {};
      }
      this.descriptor = __bind(this.descriptor, this);

      this._id = Math.createUUID();
      this.name = '';
      for (key in json) {
        value = json[key];
        this[key] = value;
      }
      this.rules = Rule.inflateRules(json['rules']);
    }

    GroupRule.prototype.descriptor = function() {
      var json;
      json = {
        _id: this._id,
        name: this.name,
        type: this.type
      };
      json.rules = Rule.deflateRules(this.rules);
      return json;
    };

    return GroupRule;

  })();

  EventGroupRule = (function(_super) {

    __extends(EventGroupRule, _super);

    function EventGroupRule(json) {
      if (json == null) {
        json = {};
      }
      this.descriptor = __bind(this.descriptor, this);

      this.type = 'group-event';
      this.event = 'idle';
      this.code = void 0;
      EventGroupRule.__super__.constructor.call(this, json);
    }

    EventGroupRule.prototype.descriptor = function() {
      var json;
      json = EventGroupRule.__super__.descriptor.call(this);
      json.event = this.event;
      json.code = this.code;
      return json;
    };

    return EventGroupRule;

  })(GroupRule);

  FlowGroupRule = (function(_super) {

    __extends(FlowGroupRule, _super);

    function FlowGroupRule(json) {
      if (json == null) {
        json = {};
      }
      this.descriptor = __bind(this.descriptor, this);

      this.type = 'group-flow';
      this.behavior = 'all';
      FlowGroupRule.__super__.constructor.call(this, json);
    }

    FlowGroupRule.prototype.descriptor = function() {
      var json;
      json = FlowGroupRule.__super__.descriptor.call(this);
      json.behavior = this.behavior;
      return json;
    };

    return FlowGroupRule;

  })(GroupRule);

  window.FlowGroupRule = FlowGroupRule;

  window.EventGroupRule = EventGroupRule;

}).call(this);
