require('coffee-script/register');
var index = require('./index.coffee');
var commandLineArgs = require('command-line-args');

var cli = commandLineArgs([
  { name: 'src', type: String},
  { name: 'skip-parse-error', alias: 's', type: Boolean}
])

var options = cli.parse()

if (!options.src)
  usage();

if (typeof options.src === 'string') {

  index(options.src, options['skip-parse-error'], function(result){
    result.forEach(function(res){
      res.forEach(function(r){
        console.log(r.name + " is not in use " + r.path);
      })
    })
  });
}

function usage(){
  console.log('usage: node index.js --src <path to walk> [--skip-parse-error or -s]');
  process.exit(1);
}