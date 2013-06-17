(function() {
  var EventGroupRule;

  EventGroupRule = (function() {

    function EventGroupRule(actor, json) {
      var key, value;
      this._id = Math.createUUID();
      this.rules = [];
      this.type = 'group-event';
      this.event = void 0;
      this.code = void 0;
      for (key in json) {
        value = json[key];
        this[key] = value;
      }
    }

    return EventGroupRule;

  })();

  window.EventGroupRule = EventGroupRule;

}).call(this);
