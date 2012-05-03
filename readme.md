grunt.vim
===========

This is a lightweight Vim plugin wrapper to [Grunt](http://gruntjs.com). Features:

* `:Grunt`, which wraps `grunt`.

* (todo) Grunt documentation as vim helpfile. Run `:Helptags` in the plugin directory
  and you'll get a bunch of `:help grunt-*` available.

* easier `:find`. The 'path' has been modified to include all the best
  places to be (`bin/`, `tasks/` and current working directory) -
  (see `:help path`, `:help find`, `:help gf`)

* `:Gtask [{name}]` Edit the specified task (in
  tasks/{name}.{js|coffee}}) or load a predefined template in current
  buffer.


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

`:Gtask [{name}]`

Edit the specified task (in tasks/{name}.{js|coffee}}) or load a
predefined template in current buffer.

(todo) A limited amount of completion should be provided.

----

**todo** below are rough feature goals of this project:

Bunch of Stuff.

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

---

"goto file" for config entry in gruntfile.


```js
c*ss: {

}
``

Should open `tasks/css.js`


