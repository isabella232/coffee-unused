esprima    = require 'esprima'
nodeType   = require './node-type'
parseRegex = require './parse-regex'


processResults = (results, path) ->
  for name of results
    if results.hasOwnProperty name
      stats = results[name]
      if stats.declarations is 0 and stats.calls is 0
        console.log 'Variable', name, 'undeclared', ' in ', path
      else if stats.declarations > 1 and stats.calls is 0
        console.log 'Variable', name, 'declared multiple times', ' in ', path
      else if stats.calls is 0
        console.log 'Variable', name, 'declared but not called', ' in ', path


traverse = (node, func) ->
  func node
  for key of node
    if node.hasOwnProperty key
      child = node[key]
      if typeof child is 'object' and child isnt null
        if Array.isArray child
          child.forEach (node) ->
              traverse node, func
        else
          traverse child, func


checkIdentifier = (node) -> node.type is nodeType.Identifier


analyzeCode = (code, path) ->
  options =
    loc : no
  ast = esprima.parse code, options
  variablesStats = {}

  addStatsEntry = (funcName) ->
    unless variablesStats[funcName]
      variablesStats[funcName] =
        calls: 0
        declarations:0


  traverse ast, (node) ->

    # variable = new Variable
    if node.type is nodeType.NewExpression
      if checkIdentifier node.callee
        addStatsEntry(node.callee.name);
        variablesStats[node.callee.name].calls += 1

    # func (var1, var2, var3)
    else if node.type is nodeType.FunctionExpression
      if node.params.length > 0
        for param in node.params
          if checkIdentifier param
            addStatsEntry param.name
            variablesStats[param.name].declarations += 1

    # variable = variable2()
    else if node.type is nodeType.CallExpression and checkIdentifier node.callee
      if node.callee.name != 'require'
        addStatsEntry node.callee.name
        variablesStats[node.callee.name].calls += 1

      if node.arguments.length > 0
        for arg in node.arguments
          if checkIdentifier arg
            addStatsEntry arg.name
            variablesStats[arg.name].calls += 1

    else if node.type is nodeType.CallExpression and node.callee.type is nodeType.FunctionExpression
      if node.arguments.length > 0
        for arg in node.arguments
          if checkIdentifier arg
            addStatsEntry arg.name
            variablesStats[arg.name].calls += 1

    # variable.func()
    else if node.type is nodeType.CallExpression and node.callee.type is nodeType.MemberExpression
      if checkIdentifier node.callee.object
        addStatsEntry node.callee.object.name
        variablesStats[node.callee.object.name].calls += 1

      if node.arguments.length > 0
        for arg in node.arguments
          if checkIdentifier arg
            addStatsEntry arg.name
            variablesStats[arg.name].calls += 1

    # variable = variable2 -- to find variable2 used
    else if node.type is nodeType.AssignmentExpression and  checkIdentifier node.right
      addStatsEntry node.right.name
      variablesStats[node.right.name].calls += 1

    # variable = this.variable2 -- to find variable2 used
    else if node.type is nodeType.AssignmentExpression and node.right.type is nodeType.MemberExpression
      if node.right.object.type
        addStatsEntry node.right.object.name
        variablesStats[node.right.object.name].calls += 1

    # variable
    else if node.type is nodeType.VariableDeclarator
      addStatsEntry node.id.name
      variablesStats[node.id.name].declarations += 1

    # 'test' : variable
    else if node.type is nodeType.Property
      if checkIdentifier node.value
        addStatsEntry node.value.name
        variablesStats[node.value.name].calls += 1

    #  variable1 <= variable2
    else if node.type is nodeType.ConditionalExpression
      if checkIdentifier node.consequent
        addStatsEntry node.consequent.name
        variablesStats[node.consequent.name].calls += 1

    # variable2 = someVariable.variable1 - variable1 is used
    else if node.type is nodeType.MemberExpression and node.property?
      if checkIdentifier node.object
        addStatsEntry node.object.name
        variablesStats[node.object.name].calls += 1

    # if (variable)
    else if node.type is nodeType.IfStatement
      if checkIdentifier node.test
        addStatsEntry node.test.name
        variablesStats[node.test.name].calls += 1

      if node.test.type is nodeType.UnaryExpression
        addStatsEntry node.test.argument.name
        variablesStats[node.test.argument.name].calls += 1

    # variable1 || variable2 or variable1 && variable2
    else if node.type is nodeType.LogicalExpression
      if checkIdentifier node.left
        addStatsEntry node.left.name
        variablesStats[node.left.name].calls += 1

      if checkIdentifier node.right
        addStatsEntry node.right.name
        variablesStats[node.right.name].calls += 1

    # comparision two variable variable1 != null or variable1 != variable2
    else if node.type is nodeType.BinaryExpression
      if checkIdentifier node.left
        addStatsEntry(node.left.name)
        variablesStats[node.left.name].calls += 1

      if checkIdentifier node.right
        addStatsEntry node.right.name
        variablesStats[node.right.name].calls += 1

    # return variable
    else if node.type is nodeType.ReturnStatement
      if node.argument? and checkIdentifier node.argument
        addStatsEntry node.argument.name
        variablesStats[node.argument.name].calls += 1

    # for pistachio variables {{#(variable)}}
    else if node.type is nodeType.Literal
      if typeof node.value is 'string'
        if node.value.match(parseRegex.pistachios)?
          for val in node.value.match(parseRegex.pistachios)
            reg = val.match parseRegex.DATA_REGEX
            if reg?
              data = parseRegex.getData reg[0]
              addStatsEntry data
              variablesStats[data].calls += 1


  processResults variablesStats, path


module.exports = analyzeCode