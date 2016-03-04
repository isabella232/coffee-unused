fs          = require 'fs'
coffee      = require 'coffee-script'
analyzeCode = require './find-unused-vars'

module.exports = (filename) ->

  code = fs.readFileSync filename, 'utf8'

  code = try coffee.compile(code)
  catch e then console.error e; code

  analyzeCode code