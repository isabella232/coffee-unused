index = require '../index.coffee'


describe "Test", ->
  describe "Unused variables for vars", ->

    it 'vars', (done) ->

      index "/Users/hakankaradis/coffee-unused/test/vars", yes, (expected) ->
        actual = [[
          {
            name: 'fs'
            path: '/Users/hakankaradis/coffee-unused/test/vars/var1.coffee:1'
            lineNumber: 1
          }
          {
            name: 'options'
            path: '/Users/hakankaradis/coffee-unused/test/vars/var1.coffee:3'
            lineNumber: 3
          }
        ]]

        expect(expected).toEqual actual
        done()

  describe "Unused variables for options", ->

    it 'options', (done) ->

      index "/Users/hakankaradis/coffee-unused/test/options", yes, (expected) ->
        console.log expected
        console.log actual
        actual = [ [
          {
            name: 'globals'
            path: '/Users/hakankaradis/coffee-unused/test/options/option.coffee:1'
            lineNumber: 1
          }
        ] ]

        expect(yes).toEqual yes
        done()






