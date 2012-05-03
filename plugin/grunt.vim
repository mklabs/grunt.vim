" grunt - A plugin to help working with Grunt
" Maintainer: mklabs

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


" spawn helper, basic wrapper to :!
function! s:Grunt(bang, args)
  let cmd = 'grunt --no-color '.a:args
  execute ':!'.cmd
endfunction


"
" Initialization
"

" detect a grunt project, a little crude right now, just checking cwd's gruntfile exists
function! s:Detect()
  let cwd = getcwd()
  let gruntfile = join([cwd, 'grunt.js'], '/')
  if filereadable(gruntfile)
    return s:GrunInit()
  endif

  let gruntfile = join([cwd, 'Gruntfile.js'], '/')
  if filereadable(gruntfile)
    return s:GrunInit()
  endif

  let gruntfile = join([cwd, 'grunt.coffee'], '/')
  if filereadable(gruntfile)
    return s:GrunInit()
  endif

  let gruntfile = join([cwd, 'Gruntfile.coffee'], '/')
  if filereadable(gruntfile)
    return s:GrunInit()
  endif
endfunction

augroup gruntDetect
  autocmd!
  autocmd BufNewFile * call s:Detect()
  autocmd VimEnter * call s:Detect()
augroup END

command! -bar -bang -nargs=* Grunt call s:Grunt(<bang>0,<q-args>)


" todo: should integrate with other plugins
"
" like NERDTree, auto refresh on some command


" vim:set sw=2 sts=2:

