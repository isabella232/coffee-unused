index = require '../index.coffee'
path  = require 'path'
fs    = require 'fs'
path  = path.dirname(fs.realpathSync(__filename))

describe "Test", ->
  describe "Unused variables for vars", ->

    it 'vars', (done) ->

      index "#{path}/vars", yes, (expected) ->
        actual = [[
          {
            name: 'fs'
            path: "#{path}/vars/var1.coffee:1"
            lineNumber: 1
          }
          {
            name: 'options'
            path: "#{path}/vars/var1.coffee:3"
            lineNumber: 3
          }
        ]]

        expect(expected).toEqual actual
        done()

  describe "Unused variables for options", ->

    it 'options', (done) ->

      index "#{path}/options", yes, (expected) ->

        actual = [ [
          {
            name: 'globals'
            path: "#{path}/options/option.coffee:1"
            lineNumber: 1
          }
        ] ]

        expect(expected).toEqual actual
        done()






