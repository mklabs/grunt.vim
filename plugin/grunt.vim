" grunt - A plugin to help working with Grunt
" Maintainer:   mklabs

if exists("g:loaded_grunt") || v:version < 700 || &cp
  finish
endif
let g:loaded_grunt = 1

" Basic Grunt wrapper
"
" so much to do
" - doesn't handle usr input (grunt init)
" - should autodetect gruntfile, and expose command only on Grunt mode
" - should provide completion
" - should bump grunt output to new buffer
" - etc. etc.
"

let s:commands = []
function! s:command(definition) abort
  let s:commands += [a:definition]
endfunction

function! s:define_commands()
  for command in s:commands
    exe 'command! '.command
  endfor
endfunction

function! s:Grunt(bang, args)
  let out = system('grunt --no-color '.a:args)
  echo out
endfunction

call s:command("-bar -bang -nargs=? Grunt :execute s:Grunt(<bang>0,<q-args>)")

call s:define_commands()


" vim:set sw=2 sts=2:

