grunt.vim
===========

This is a lightweight wrapper to Grunt
[Grunt](http://gruntjs.com). Features:

* `:Grunt`, which wraps `grunt`.
* (todo) Grunt documentation as vim helpfile. Run `:Helptags` in the plugin directory
  and you'll get a bunch of `:h grunt-*` available.


Installation
------------

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/mklabs/vim-grunt.git

(todo) Once help tags have been generated, you can view the manual with
`:help grunt`.


Commands
--------

`:Grunt`

A really simpe wrapper to `grunt` (should be installed and available in your
`$PATH`. If `grunt --version` display works, so do `:Grunt`.

----

**todo** below are rough feature goals of this project:

Bunch of Stuff.

---

Detect a grunt project. A simple thing (not as evolved as vim-rails)

Probably by looking up and searching in the app directory for files like: `grunt.{js|coffee]`, `Gruntfile.{js|coffee}`

if there is, add commands and all plugin stuff.

Only one (or very few command) should be made global.

---

path manipulation. `:h path`. So that we can `:find things` super-easily.

* Add ./
* Add tasks/
* Add bin/

---

Command `:Gtask` -> like vim-rails' `:R<command>` family of commands (says :Rcontroller)

Easily jump to a given grunt task (like `:find` only on tasks dirs)

---

Command `:Grunt`. Basic wrapper to `grunt executable` (like vim-rails' `:Rake`)

Use `:!` instead of `system`

Open the quickfix window if there were any errors.

---

Command `:Glint` special purpose grunt lint command.

Open the quickfix window if there were any errors, plus...

Super-handy mapping to jump to the given file, at the given line number (file under cursor)

---

Command `:Gtest` special purpose grunt test command (really similar to `:Glint`)

Open the quickfix window if there were any errors, plus...

Super-handy mapping to jump to the given file, at the given line number (file under cursor)

---

Grunt documentation as helpfiles, from doc/*.markdown in grunt repository.

----

Todo: rewatch vim screencast on fugitive, trying to take inspiration, figure out what is possible to do.







