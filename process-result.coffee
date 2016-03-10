module.exports = processResults = (results, path) ->
  originalResult = []
  for name of results
    if results.hasOwnProperty name
      result = {}
      stats = results[name]
      if stats.declarations is 0 and stats.calls is 0
        console.log 'Variable', name, 'undeclared', ' in ', path
      else if stats.declarations > 1 and stats.calls is 0
        result =
          name       : name
          path       : "#{path}:#{stats.declaredLine}"
          lineNumber : stats.declaredLine
        originalResult.push result
      else if stats.calls is 0
        result =
          name       : name
          path       : "#{path}:#{stats.declaredLine}"
          lineNumber : stats.declaredLine
        originalResult.push result

  return originalResult