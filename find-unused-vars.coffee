esprima    = require 'esprima'
NodeType   = require './node-type'
parseRegex = require './parse-regex'


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


checkIdentifier = (node) -> node.type is NodeType.Identifier


analyzeCode = (code, path) ->
  options =
    loc : no
  ast = esprima.parse code, options
  variablesStats = {}

  addStatsEntry = (funcName) ->

    return if variablesStats[funcName]

    variablesStats[funcName] =
      calls: 0
      declarations:0


  traverse ast, (node) ->

    switch node.type
      # variable = new Variable
      when NodeType.NewExpression
        if checkIdentifier node.callee
          addStatsEntry node.callee.name
          variablesStats[node.callee.name].calls += 1

      # func (var1, var2, var3)
      when NodeType.FunctionExpression
        if node.params.length > 0
          for param in node.params
            if checkIdentifier param
              addStatsEntry param.name
              variablesStats[param.name].declarations += 1

      when NodeType.CallExpression
        switch node.callee

          # variable = variable2()
          when NodeType.Identifier
            if node.callee.name != 'require'
              addStatsEntry node.callee.name
              variablesStats[node.callee.name].calls += 1

            if node.arguments.length > 0
              for arg in node.arguments
                if checkIdentifier arg
                  addStatsEntry arg.name
                  variablesStats[arg.name].calls += 1

          when NodeType.FunctionExpression
            if node.arguments.length > 0
              for arg in node.arguments
                if checkIdentifier arg
                  addStatsEntry arg.name
                  variablesStats[arg.name].calls += 1

          # variable.func()
          when NodeType.MemberExpression
            if checkIdentifier node.callee.object
              addStatsEntry node.callee.object.name
              variablesStats[node.callee.object.name].calls += 1

            if node.arguments.length > 0
              for arg in node.arguments
                if checkIdentifier arg
                  addStatsEntry arg.name
                  variablesStats[arg.name].calls += 1

      when NodeType.AssignmentExpression
        switch node.right

          # variable = variable2 -- to find variable2 used
          when NodeType.Identifier
            addStatsEntry node.right.name
            variablesStats[node.right.name].calls += 1

          # variable = this.variable2 -- to find variable2 used
          when NodeType.MemberExpression
            if node.right.object.type
              addStatsEntry node.right.object.name
              variablesStats[node.right.object.name].calls += 1

      # variable
      when NodeType.VariableDeclarator
        addStatsEntry node.id.name
        variablesStats[node.id.name].declarations += 1

      # 'test' : variable
      when NodeType.Property
        if checkIdentifier node.value
          addStatsEntry node.value.name
          variablesStats[node.value.name].calls += 1

      #  variable1 <= variable2
      when NodeType.ConditionalExpression
        if checkIdentifier node.consequent
          addStatsEntry node.consequent.name
          variablesStats[node.consequent.name].calls += 1

      # variable2 = someVariable.variable1 - variable1 is used
      when NodeType.MemberExpression
        if node.property?
          if checkIdentifier node.object
            addStatsEntry node.object.name
            variablesStats[node.object.name].calls += 1

      # if (variable)
      when NodeType.IfStatement
        switch node.test

          when NodeType.Identifier
            addStatsEntry node.test.name
            variablesStats[node.test.name].calls += 1

          when NodeType.UnaryExpression
            addStatsEntry node.test.argument.name
            variablesStats[node.test.argument.name].calls += 1

      # variable1 || variable2 or variable1 && variable2
      when NodeType.LogicalExpression
        if checkIdentifier node.left
          addStatsEntry node.left.name
          variablesStats[node.left.name].calls += 1

        if checkIdentifier node.right
          addStatsEntry node.right.name
          variablesStats[node.right.name].calls += 1

      # comparision two variable variable1 != null or variable1 != variable2
      when NodeType.BinaryExpression
        if checkIdentifier node.left
          addStatsEntry(node.left.name)
          variablesStats[node.left.name].calls += 1

        if checkIdentifier node.right
          addStatsEntry node.right.name
          variablesStats[node.right.name].calls += 1

      # return variable
      when NodeType.ReturnStatement
        if node.argument? and checkIdentifier node.argument
          addStatsEntry node.argument.name
          variablesStats[node.argument.name].calls += 1

      # for pistachio variables {{#(variable)}}
      when NodeType.Literal
        if typeof node.value is 'string'
          if node.value.match(parseRegex.pistachios)?
            for val in node.value.match(parseRegex.pistachios)
              reg = val.match parseRegex.DATA_REGEX
              if reg?
                data = parseRegex.getData reg[0]
                addStatsEntry data
                variablesStats[data].calls += 1

  variablesAndPath =
    stats : variablesStats
    path : path
  return variablesAndPath


module.exports = analyzeCode