(function() {
  var FlowGroupRule;

  FlowGroupRule = (function() {

    function FlowGroupRule(actor, json) {
      var key, value;
      this._id = Math.createUUID();
      this.rules = [];
      this.type = 'group-flow';
      for (key in json) {
        value = json[key];
        this[key] = value;
      }
    }

    return FlowGroupRule;

  })();

  window.FlowGroupRule = FlowGroupRule;

}).call(this);
