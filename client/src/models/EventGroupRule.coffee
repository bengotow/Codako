class EventGroupRule

  constructor: (actor, json) ->
    @_id = Math.createUUID()
    @rules = []
    @type = 'group-event'
    @event = undefined
    @code = undefined
    @[key] = value for key, value of json

window.EventGroupRule = EventGroupRule
