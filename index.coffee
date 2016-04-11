fs            = require 'fs'
walk          = require 'walk'
analyzeCode   = require './find-unused-vars'
processResult = require './process-result'
async = require 'async'

module.exports = (folder, skipParseError, callback) ->

  ignoredDirectories = ['node_modules']

  lookForFile = {}
  pathToWalk  = folder
  walker      = walk.walk pathToWalk, {}
  originalResult = []


  readfile = (path, callback) ->
    fs.readFile path, 'utf8', (err, code)->
      return callback err if err and not skipParseError

      varsAndPath = analyzeCode code, path, skipParseError
      result = processResult varsAndPath.stats, varsAndPath.path
      originalResult.push result  if result.length > 0
      callback null


  q = async.queue(readfile, 5)

  walker.on "file", (root, fileStats, next) ->
    return next() if root in ignoredDirectories

    if /\.coffee$/.test fileStats.name
      fileName = "#{root}/#{fileStats.name}"
      q.push fileName

    next()

  walker.on "end", () ->

    q.drain = () ->
      q.kill()
      callback originalResult


