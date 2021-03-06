esprima    = require 'esprima'
NodeType   = require './node-type'
parseRegex = require './parse-regex'
parse      = require('decaffeinate-parser').parse
transform  = require 'coffee-react-transform'

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


analyzeCode = (code, path, skipParseError) ->

  # parse the coffee file decaffeinate-parser
  ast = try parse code
  catch e
    unless skipParseError
      console.log "Error occured parsing the file #{path}"
    # when parsing error occured try to parse code with transform
    # transform is for parsing jsx
    code = try transform code
    catch e
      unless skipParseError
        console.log 'Error occured while compiling to js...'
    ast = try parse code
    catch e
      unless skipParseError
        console.log "Error occured parsing the file #{path}"

  variablesStats = {}

  assignDeclaration = (node) ->

    if node.type is NodeType.Identifier
      addStatsEntry node.data
      variablesStats[node.data].declaredLine = node.line
      variablesStats[node.data].declarations += 1


  assignCall = (node) ->

    if node.type is NodeType.Identifier
      addStatsEntry node.data
      variablesStats[node.data].calledLine = node.line
      variablesStats[node.data].calls += 1


  addStatsEntry = (funcName) ->

    return if variablesStats[funcName]

    variablesStats[funcName] =
      calls: 0
      calledLine: 0
      declarations: 0
      declaredLine: 0


  traverse ast, (node) ->

    switch node?.type

      # variable = something
      when NodeType.AssignOp
        if node.assignee? #and node.expresssion? and node.expression.type isnt NodeType.Identifier
          if node.expression.type isnt 'Function'
            assignDeclaration node.assignee

        if node.expression?
          assignCall node.expression

        # extends Variable
        if node.expression?
          if node.expression.type is NodeType.Class
            if node.expression.parent?
              assignCall node.expression.parent

      # for k,v of variable
      when NodeType.ForOf, NodeType.ForIn
        if node.keyAssignee?
          assignDeclaration node.keyAssignee
        if node.valAssignee
          assignDeclaration node.valAssignee
        if node.target?
          assignCall node.target

      # variable.func()
      when NodeType.MemberAccessOp
        if node.expression?
          assignCall node.expression

        if node.memberName?
          addStatsEntry node.memberName
          variablesStats[node.memberName].calls += 1

      # func(var1, var2, ...)
      when NodeType.FunctionApplication
        if node.arguments?
          for n in node.arguments
            assignCall n

        if node.function?
          assignCall node.function

      # new Variable
      when NodeType.NewOp
        if node.ctor?
          assignCall node.ctor

        if node.arguments?
          for argument in node.arguments
            assignCall argument

      # if | unless Varibale
      # return Variable
      # variable ?= variable
      when NodeType.Conditional, NodeType.Return, NodeType.CompoundAssignOp
        if node.condition?
          assignCall node.condition

        if node.expression?
          assignCall node.expression

      # #{variable}
      when NodeType.TemplateLiteral
        if node.expressions?
          for expression in node.expressions
            assignCall expression

      # something = {variable, variable2}
      when NodeType.ObjectInitialiser
        if node.members?
          for member in node.members
            member.type = NodeType.Identifier
            if member.raw.indexOf(':') is -1
              member.data = member.raw
            else
              member.data = member.raw.split(':')[1]
            assignCall member

      # var : variable
      when NodeType.Identifier, NodeType.DoOp, NodeType.Switch
        if node.expression?
          assignCall node.expression


      # var1 or var2
      # if variable1 isnt variable2
      # if var1 and var2, var1 + var2
      when NodeType.LogicalOrOp, NodeType.LeftShiftOp, NodeType.ExtendsOp, NodeType.GTOp, NodeType.InOp, NodeType.PlusOp, NodeType.ExistsOp, NodeType.NEQOp, NodeType.LogicalAndOp, NodeType.EQOp, NodeType.InstanceofOp, NodeType.LTOp, NodeType.DivideOp, NodeType.SubtractOp
        if node.left?
          assignCall node.left
        if node.right?
          assignCall node.right

      # if variable?
      # not variable
      # variable[something] then .map
      when NodeType.UnaryExistsOp, NodeType.LogicalNotOp, NodeType.DynamicMemberAccessOp
        if node.expression?
          assignCall node.expression
        if node.indexingExpr?
          assignCall node.indexingExpr

      when NodeType.Block
        if node.statements?
          for statement in node.statements
            if statement?
              assignCall statement

      when NodeType.PostIncrementOp
        if node.expression?
          assignCall node.expression

      when NodeType.ArrayInitialiser
        if node.members?
          for member in node.members
            assignCall member

      when NodeType.ProtoMemberAccessOp, NodeType.SoakedMemberAccessOp, NodeType.PreDecrementOp
        if node.expression?
          assignCall node.expression

      when NodeType.SwitchCase
        if node.conditions?
          for condition in node.conditions
            assignCall condition

      when NodeType.BoundFunction
        if node.parameters?
          for parameter in node.parameters
            assignCall parameter

      when NodeType.Class
        if node.parent?
          assignCall node.parent

      when NodeType.SoakedDynamicMemberAccessOp
        if node.indexingExpr?
          assignCall node.indexingExpr

  variablesAndPath =
    stats : variablesStats
    path : path
  return variablesAndPath


module.exports = analyzeCode