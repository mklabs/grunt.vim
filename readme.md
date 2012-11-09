grunt.vim
=========

*A lightweight wrapper to Grunt, so that you could grunt things directly from Vim*

This plugin tries to detect a valid Gruntfile
(`{grunt|Gruntfile}.{js|coffee}`), in the current working directory. If
it does, it defines a handy set of commands to work with grunt test or
lint task, to browse one of grunt documentation page and significantly
ease navigation of the Grunt directory structure.

There are a lot more features I'd like to see implemented or further improved,
but it's already been quite useful to me. Features:

* Interface to `grunt`.  Use `:Grunt` to run the given task(s), really
  similar to directly running `:!grunt --no-color <task, ...>`.

* Grunt documentation as vim helpfile. Run `:Helptags` in the plugin
  directory and you'll get a bunch of `:help grunt-*` available. These
  `doc/*.txt` helpfiles are generated automatically from markdown files
  in grunt repository.

* Easy navigation of the Grunt directory structure. `gf` and `:find`
  know about task and test files. The `path` has been modified to
  include current directory, `tasks/`, and `bin/`. For more advanced
  usage, `:Gtask`, `:Gtest` commands are provided.

* `:Gtask [{name}]` Edit the specified task (in
  tasks/{name}.{js|coffee}}) or load a predefined template in current
  buffer. `:Gtask <tab>` works too.

* `:Gtest {name}` Edit the specified test or load a predefined template
  in current buffer. `:Gtest <tab>` works too.

* Integration with [quickfix
  window](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#quickfix-window)
  for displaying errors in grunt test or lint task.

* `:Glint` runs `grunt lint` and collects output for quickfix window
  display.

* `:Gtest` without arguments acts pretty much like `:Glint`.

* `:Gdoc` is a simple and handy command to open a web browser
  to one of the Grunt docuementation page on github. Just like, `:Gtest`
  or `:Gtask`, a limited amount of completion is supported.

Installation
------------

Using [pathogen.vim](https://github.com/tpope/vim-pathogen) is the best way to
install this plugin. Actually, some of pathogen function helpers are
used internally, so pathogen might very well be considered as one of
grunt.vim dependency.

    cd ~/.vim/bundle
    git clone git://github.com/mklabs/grunt.vim.git

Once help tags have been generated (either manually with `:helptags` or
via pathogen's `:Helptags` which might very well be directly put in your
`.vimrc`)  you can view the manual with `:help grunt`.

This plugin also assumes both node and grunt are installed and available in
your `$PATH`, but that sounds reasonable for a Vim Grunt plugin.

quickfix
--------

grunt.vim will automatically display errors in the quickfix window.

See `:h quickfix`

> In the quickfix window, each line is one error.  The line number is equal to
> the error number.  You can use ":.cc" to jump to the error under the cursor.
> Hitting the <Enter> key or double-clicking the mouse on a line has the same
> effect.  The file containing the error is opened in the window above the
> quickfix window.  If there already is a window for that file, it is used

Once an error is fixed the corresponding quickfix line will disappear.
This works either way, the quickfix window is updated on file save,
whenever `:Gtest` or `:Glint` commands detect error output.

Configuration
-------------

Pretty minimal. No configuration hooks for now (except from
`g:loaded_grunt` that if set to 1 in your `.vimrc` will prevent the
plugin from being loaded)

A few notes
-----------

This plugin cares about the current working directory. Open Vim from
within a directory with a valid Gruntfile (`grunt.js`, `grunt.coffee`,
`Gruntfile.js` or `Gruntfile.coffee`)

The only command always available is `:Grunt`.


License & Acknowledgement
-------------------------

A lot of the codebase is either directly inspired, or extracted from Tim
pope's most excellent [vim-rails](https://github.com/tpope/vim-rails)
plugin.

Similarly, `pathogen#glob` function is the main handler of the few
completion function grunt.vim provides.

Also, the handy
[`parsejson#ParseJSON`](http://vim.sourceforge.net/scripts/script.php?script_id=3446)
utility is used and included in `autoload/`, as a library script.

License: Same as the three plugins mentioned above, same as Vim. See
`:help license`.

