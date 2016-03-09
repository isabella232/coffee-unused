require('coffee-script/register');
var index = require('./index.coffee');
var commandLineArgs = require('command-line-args');

var cli = commandLineArgs([
  { name: 'unused-vars', alias: 'v', type: Boolean },
  { name: 'src', type: String},
  { name: 'skip-parse-error', alias: 's', type: Boolean}
])

var options = cli.parse()

if (options['unused-vars'] && options['unused-reqs'])
  usage();

if (!options.src)
  usage();

if (typeof options.src === 'string') {
  if (options['unused-vars']) {
    index(options.src, options['skip-parse-error']);
  }
}

function usage(){
  console.log('usage: node index.js --src <path to walk> [--unused-vars or -v] [--skip-parse-error or -s]');
  process.exit(1);
}