class GroupRule

  constructor: (json = {}) ->
    @_id = Math.createUUID()
    @name = ''
    @[key] = value for key, value of json
    @rules = Rule.inflateRules(json['rules'])

  descriptor: () =>
    json = {
      _id: @_id,
      name: @name,
      type: @type
    }
    json.rules = Rule.deflateRules(@rules)
    json


class EventGroupRule extends GroupRule

  constructor: (json = {}) ->
    @type = 'group-event'
    @event = 'idle'
    @code = undefined
    super(json)

  descriptor: () =>
    json = super()
    json.event = @event
    json.code = @code
    json



class FlowGroupRule extends GroupRule

  constructor: (json = {}) ->
    @type = 'group-flow'
    @behavior = 'all'
    super(json)

  descriptor: () =>
    json = super()
    json.behavior = @behavior
    json

window.FlowGroupRule = FlowGroupRule
window.EventGroupRule = EventGroupRule
