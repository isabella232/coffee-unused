module.exports = processResults = (results, path) ->
  for name of results
    if results.hasOwnProperty name
      stats = results[name]
      if stats.declarations is 0 and stats.calls is 0
        console.log 'Variable', name, 'undeclared', ' in ', path
      else if stats.declarations > 1 and stats.calls is 0
        console.log "Variable #{name} declared multiple times in #{path}:#{stats.declaredLine}"
      else if stats.calls is 0
        console.log "Variable #{name} declared but not called in #{path}:#{stats.declaredLine}"