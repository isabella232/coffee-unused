# coffee-unused

The module helps you to identify unused varibales in your coffescript project.
The module find all unused variables under given directory and returns array of objects
specifying name, path and line number

```
  [[
    {
      name: 'fs'
      path: 'directory_path/vars/var1.coffee:1'
      lineNumber: 1
    }
    {
      name: 'options'
      path: 'directory_path/vars/var1.coffee:3'
      lineNumber: 3
    }
  ]]
```


## Usage

```
node ./node_modules/index.js --src <path to walk>  [--skip-parse-error]

-s alias for '--skip-parse-error'

```

## Install

```
npm install coffee-unused
```