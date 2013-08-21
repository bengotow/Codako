
class T8NError extends Error
  error_type: null
  error_substitutions: null

  constructor: (error_type, error_substitutions = null) ->
    @error_type = error_type
    @error_substitutions = error_substitutions
    super

  toString: () ->
    return T8N(@error_type, @error_substitutions)


module.exports = T8NError