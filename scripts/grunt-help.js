
// Module dependencies

var fs = require('fs'),
  path = require('path'),
  util = require('util'),
  stream = require('stream'),
  spawn = require('child_process').spawn;


function GruntHelp(opts) {
  this.readable = true;
  this.writable = true;
  this.chunks = [];
  this.opts = opts || {};

  this.matchers = this.opts.matchers || {
    filename: /(.+)\.(js|coffee)/,
    message: /AssertionMessage:?\s*\u001b\[35m\s*([^\u001b]+)/,
    error: /Error:?\s*\u001b\[35m\s*([^\u001b]+)/
  };


  stream.Stream.call(this);
}

util.inherits(GruntHelp, stream.Stream);

GruntHelp.prototype.write = function(chunk) {
  this.chunks = this.chunks.concat(chunk);
};

GruntHelp.prototype.end = function() {
  // parse streaming markdown
  var data = this.parse(this.chunks.join(''));
  this.emit('data', data);
  this.emit('end');
};

GruntHelp.prototype.parse = function(body) {
  // split by tasks. Matching "Testing (filename)"

  var matchers = this.matchers;

  var data = body.split(/Testing\s*|WARN/).filter(function(file) {
    return matchers.filename.test(file);
  }).map(function(file) {
    var filename = file.match(matchers.filename)[0];

    var linematcher = new RegExp(filename + ':(\\d+)');

    var errors = file.split(/^$/m).filter(function(er) {
      return er.trim() && />>\s*/.test(er);
    }).map(function(er) {
      var message = (er.match(matchers.message) || [])[1],
        error = (er.match(matchers.error) || [])[1],
        line = (er.match(linematcher) || [])[1];

      return {
        message: message || '',
        error: error || '',
        line: line || 0
      };
    });

    return {
      name: filename,
      errors: errors
    };
  });

  return JSON.stringify({
    errors: data
  });
};

process.openStdin()
  .pipe(new GruntHelp())
  .pipe(process.stdout);
