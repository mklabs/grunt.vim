" grunt - A plugin to help working with Grunt
" Maintainer: mklabs

if exists("g:loaded_grunt") || v:version < 700 || &cp
  finish
endif
let g:loaded_grunt = 1

"
" Utility
"

" spawn helper, basic wrapper to :!
function! s:Grunt(bang, args)
  let cmd = 'grunt --no-color '.a:args
  execute ':!'.cmd
endfunction

" set base path utility, for easier `:find`, super simplified here.
" Should be improved.
function! s:SetBasePath()
  " current directory + tasks and bin
  let path = ['', 'tasks/', 'bin/']
  :let &path=join(path, ',')
endfunction

"
" Initialization
"

" detect a grunt project, a little crude right now, just checking cwd's
" gruntfile exists todo: it shoulld detect on both cwd (when starting
" vim from console) and actual vim path (eg. vim ./some/nested/path) to
" handle both case
function! s:Detect()
  let cwd = getcwd()
  let gruntfile = join([cwd, 'grunt.js'], '/')
  if filereadable(gruntfile)
    return s:GruntInit()
  endif

  let gruntfile = join([cwd, 'Gruntfile.js'], '/')
  if filereadable(gruntfile)
    return s:GruntInit()
  endif

  let gruntfile = join([cwd, 'grunt.coffee'], '/')
  if filereadable(gruntfile)
    return s:GruntInit()
  endif

  let gruntfile = join([cwd, 'Gruntfile.coffee'], '/')
  if filereadable(gruntfile)
    return s:GruntInit()
  endif
endfunction


" Grunt init
function! s:GruntInit()
  call s:SetBasePath()
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

