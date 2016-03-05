fs          = require 'fs'
walk        = require 'walk'
coffee      = require 'coffee-script'
analyzeCode = require './find-unused-vars'

module.exports = (folder) ->

  lookForFile = {}
  pathToWalk  = folder
  walker      = walk.walk pathToWalk, {}

  walker.on "file", (root, fileStats, next) ->
    if root.indexOf('node_modules') is -1
      checkUsedFiles = {}
      fs.readFile fileStats.name, () ->
        if fileStats.name.endsWith '.coffee'
          openFile = "#{root}/#{fileStats.name}"
          lookForFile["#{openFile}"] = 1

    next()


  walker.on "end", () ->

    for path, value of lookForFile

      code = fs.readFileSync path, 'utf8'
      code = try coffee.compile(code)
      catch e then console.error e; code

      analyzeCode code, path


