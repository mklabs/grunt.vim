" grunt - A plugin to help working with Grunt
" Maintainer: mklabs

if exists("g:loaded_grunt") || v:version < 700 || &cp
  finish
endif
let g:loaded_grunt = 1

let s:cwd = getcwd()
let s:dirname=expand('<sfile>:h:h')


"
" Utility
"

" spawn helper, basic wrapper to :!
function! s:Grunt(bang, args)
  let cmd = 'grunt --no-color '.a:args
  execute ':!'.cmd
endfunction

" Set base path utility, for easier `:find`, super simplified here.
" Should be improved.
function! s:SetBasePath()
  " current directory + tasks and bin
  let path = ['', 'tasks/', 'bin/']
  :let &path=join(path, ',')
endfunction

" Setup openURL command at starup, borrowed to vim-rails
" https://github.com/tpope/vim-rails/blob/master/autoload/rails.vim#L1331-1345
function! s:initOpenURL()
  if !exists(":OpenURL")
    if has("gui_mac") || has("gui_macvim") || exists("$SECURITYSESSIONID")
      command -bar -nargs=1 OpenURL :!open <args>
    elseif has("gui_win32")
      command -bar -nargs=1 OpenURL :!start cmd /cstart /b <args>
    elseif executable("sensible-browser")
      command -bar -nargs=1 OpenURL :!sensible-browser <args>
    elseif executable('launchy')
      command -bar -nargs=1 OpenURL :!launchy <args>
    elseif executable('git')
      command -bar -nargs=1 OpenURL :!git web--browse <args>
    endif
  endif
endfunction

"
" Commands
"

" define commands loaded only on GruntDetect
function! s:GruntCommands()
  command! -bar -bang -nargs=* Gtask call s:GTask(<bang>0,<q-args>)
  command! -bar -nargs=1 -bang Gdoc call s:GDoc(<bang>0,<q-args>)
endfunction

" Task command -> :Gdoc
"
" Open a given grunt doc page in default browser
" borrowed to vim-rails
function! s:GDoc(bang, page)
  let url = 'https://github.com/cowboy/grunt/blob/master/docs/'.a:page.'.md'
  echo '... Opening ' . url . ' ...'
  if exists(':OpenURL')
    exe 'OpenURL '.url
  else
    return s:error('No :OpenURL command found')
  endif
endfunction

function! s:error(str)
  echohl ErrorMsg
  echo  a:str
  echohl None
endfunction



" Task command -> :Gtask
" Find a given tasks in ./tasks (make it configurable in some way?,
" should introspect gruntfile for grunt.loadTasks?
function! s:GTask(bang, args)
  " now a simple wrapper to `:edit` in tasks dir. Not even checking if
  " file exists, completion, etc. to be improved
  " - should edit / create buffer instead

  " for now, we handle just the first arg
  let file = get(split(a:args), 0)

  " dumb-guess of task path, this is now always the cwd/tasks/:file
  let task = join([s:cwd, 'tasks', file], '/')

  let taskname = fnamemodify(task, ':.')

  let js = filereadable(task.'.js')
  let cs = filereadable(task.'.coffee')

  if !cs && !js
    " todo: put this in function. add plaholder ability, replace
    " placeholder based on taskname.
    echo "No ". taskname ." task created yet"
    let template=join([s:dirname, 'template', 'task.js'], '/')
    echo "Loading from template ".template
    exe "silent! 0r" template
    setlocal filetype=javascript
    return
  endif

  let task = task.(cs ? '.coffee' : '.js')
  execute "edit" task
endfunction

"


"
" Initialization
"

" detect a grunt project, a little crude right now, just checking cwd's
" gruntfile exists todo: it shoulld detect on both cwd (when starting
" vim from console) and actual vim path (eg. vim ./some/nested/path) to
" handle both case
function! s:Detect()
  let gruntfile = join([s:cwd, 'grunt.js'], '/')
  if filereadable(gruntfile)
    return s:GruntInit()
  endif

  let gruntfile = join([s:cwd, 'Gruntfile.js'], '/')
  if filereadable(gruntfile)
    return s:GruntInit()
  endif

  let gruntfile = join([s:cwd, 'grunt.coffee'], '/')
  if filereadable(gruntfile)
    return s:GruntInit()
  endif

  let gruntfile = join([s:cwd, 'Gruntfile.coffee'], '/')
  if filereadable(gruntfile)
    return s:GruntInit()
  endif
endfunction


" Grunt init
function! s:GruntInit()
  " narrow the path for easier find
  call s:SetBasePath()
  " setup openURL command
  call s:initOpenURL()
  " grunt-project commands
  call s:GruntCommands()
endfunction

augroup gruntDetect
  autocmd!
  autocmd VimEnter * call s:Detect()
augroup END

command! -bar -bang -nargs=* Grunt call s:Grunt(<bang>0,<q-args>)


" todo: should integrate with other plugins
"
" like NERDTree, auto refresh on some command


" vim:set sw=2 sts=2:

