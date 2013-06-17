class FlowGroupRule

  constructor: (actor, json) ->
    @_id = Math.createUUID()
    @rules = []
    @type = 'group-flow'
    @[key] = value for key, value of json

window.FlowGroupRule = FlowGroupRule
