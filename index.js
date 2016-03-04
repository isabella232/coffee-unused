require('coffee-script/register')
var index = require('./index.coffee')

if (process.argv.length < 3) {
  console.log('Usage: analyze.coffee file.coffee');
  process.exit(1)
}

index(process.argv[2])
