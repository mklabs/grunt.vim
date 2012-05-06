
// Module dependencies

var fs = require('fs'),
  path = require('path');


//
// A simple script to filter plugin sourcefile to just markdown comments
// and have the helpfile stub generated from that.
//


var plugin = fs.readFileSync(path.join(__dirname, '../plugin/grunt.vim'), 'utf8');


var lines = plugin.split('\n').filter(function(line) {
  return (/^\s*\"/).test(line);
}).map(function(line) {
  return line.replace(/^"\s*/, '');
});

console.log(lines.join('\n'));
