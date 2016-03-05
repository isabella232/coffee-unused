require('coffee-script/register')
var vars = require('./vars')
var reqs = require('./find-unused-reqs')

if (process.argv.length < 3) {
  console.log('Usage: analyze.coffee file.coffee');
  process.exit(1)
}

vars(process.argv[2])
//reqs(process.argv[2])
