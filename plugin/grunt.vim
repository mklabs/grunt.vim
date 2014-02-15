" grunt - A plugin to help working with Grunt
" Maintainer: mklabs

if exists("g:loaded_grunt") || v:version < 700 || &cp
  finish
endif

let g:loaded_grunt = 1

let s:cwd = getcwd()
let s:dirname=expand('<sfile>:h:h')

"
" # grunt.vim
"

"
" todo:
"   - should probably do the grunt detect only on buff enter, instead of
"   once at VimEnter. Mappings and commands would only take effect on
"   current buffer
"   - if it gets longer (and it will), put the bulk of the plugin in
"   autoload.
"   - commands should be prefixed by something setup by user, and this
"   should default to :G<cmd>, so that it can be set to something else
"   like :GR<cmd>, or :Grunt<cmd>.  The fugitive family of :G<cmd> with
"   grunt ones may be confusing in tab completions.
"

"
" ## Utility
"

" spawn helper, basic wrapper to :!
function! s:Grunt(bang, args)
  let cmd = 'grunt '.a:args
  execute ':!'.cmd
endfunction

" Set base path utility, for easier `:find`, super simplified here.
" Should be improved. (:h find)
function! s:SetBasePath()
  " current directory + tasks and bin
  let path = ['', 'tasks/', 'bin/']
  :let &path=join(path, ',')
endfunction

" Used in gf command. Set includeexpr to append .js / .coffee files
" automatically. Make it possible to easily 'goto file' with tasks.
" (:h includeexpr). The find logic should be improved and be a little
" bit more dynamic. Ideally, it should be easy to also jump to one of
" the grunt source file (resolved globally or locally)
function! s:InitFind()
  :let &suffixesadd=".js,.coffee"
endfunction

" completion filter helper. borrowed to vim-rails:
" https://github.com/tpope/vim-rails/blob/master/autoload/rails.vim#L2162-2173
function! s:completion_filter(results,A)
  let results = sort(type(a:results) == type("") ? split(a:results,"\n") : copy(a:results))
  call filter(results,'v:val !~# "\\~$"')
  let filtered = filter(copy(results),'s:startswith(v:val,a:A)')
  if !empty(filtered) | return filtered | endif
  let regex = s:gsub(a:A,'[^/]','[&].*')
  let filtered = filter(copy(results),'v:val =~# "^".regex')
  if !empty(filtered) | return filtered | endif
  let regex = s:gsub(a:A,'.','[&].*')
  let filtered = filter(copy(results),'v:val =~# regex')
  return filtered
endfunction

" same here: https://github.com/tpope/vim-rails/blob/master/autoload/rails.vim#L35-41
function! s:gsub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:startswith(string,prefix)
  return strpart(a:string, 0, strlen(a:prefix)) ==# a:prefix
endfunction

function! s:error(str)
  echohl ErrorMsg
  echo  a:str
  echohl None
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

" template helper, loads a template from the template/ directory
function! s:load_template(file, name)
  let filename = fnamemodify(a:name, ':.')
  let template = join([s:dirname, 'template', a:file], '/')

  echo "No ". filename ." created yet"
  echo "Loading from template ".template

  exe "silent! 0r" template
  setlocal filetype=javascript
endfunction


" Quickfix helper. Takes an output from external program (most likely
" grunt here, with lint or test task), an three splitting patterns. One
" for splitting by 'error block', second to match the given filename,
" the third to match error message
function! s:QuickFix(output, spliterror, splitname, splitline)
  " quickfix list of errors
  let qflist = []
  for error in split(a:output, a:spliterror)
    " get file
    let filename = matchstr(error, a:splitname)
    if empty(filename)
      continue
    endif

    let parts = filter(matchlist(error, a:splitline)[1:], '!empty(v:val)')
    if empty(parts)
      continue
    endif

    let line = parts[0]
    let col = parts[1]
    let reason = split(parts[2], '\n')[0]
    let snippet = split(parts[2], '\n')[1]

    :call s:QuickFixAdd(qflist, filename, line, reason)
  endfor

  " update the qflist with action set to 'r'
  call setqflist(qflist, 'r')

  " close / open quickfix window depending on errors length
  let hasError = !empty(qflist)
  exe (hasError ? 'copen' : 'cclose')

  return hasError
endfunction


" Store the error and add line for the quickfix window
function! s:QuickFixAdd(qflist, name, line, reason)
  let qfitem = {}
  let qfitem.filename = a:name
  let qfitem.lnum = a:line
  let qfitem.text = a:reason
  let qfitem.type = 'E'
  call add(a:qflist, qfitem)
endfunction

"
" ## Completion
"

" will probably write a node script to get this back from github api
" for now, a simple
"
"     $('.js-slide-to[id]').map(function(i, el) { return el.innerText; });
"
" in my devtool at https://github.com/cowboy/grunt/tree/master/docs
function! s:Complete_docs(A,L,P)
  let pages = [
    \ 'api', 'api_config', 'api_fail', 'api_file', 'api_log',
    \ 'api_task', 'api_template', 'api_utils', 'contributing',
    \ 'example_gruntfiles', 'exit_codes', 'faq', 'getting_started',
    \ 'helpers_directives', 'plugins', 'task_concat', 'task_init',
    \ 'task_lint', 'task_min', 'task_qunit', 'task_server',
    \ 'toc', 'types_of_tasks']
  return s:completion_filter(pages, a:A)
endfunction

" Completion helper for Gtask. Globs the tasks/ directory for any
" .js or .coffee files. This currently implies and won't work if pathogen is
" not used. But pathogen is pretty common in vim config now, should probably
" add a few safeguard checks.
function! s:Complete_task(A,L,P)
  let taskjs = pathogen#glob('tasks/**/*.js')
  let taskcs = pathogen#glob('tasks/**/*.coffee')
  " really? array concat in vimscript simply means using the + operator
  " love it
  return s:completion_filter(taskjs + taskcs, a:A)
endfunction

function! s:Complete_test(A,L,P)
  let taskjs = pathogen#glob('test/**/*.js')
  let taskcs = pathogen#glob('test/**/*.coffee')
  return s:completion_filter(taskjs + taskcs, a:A)
endfunction


"
" ## Commands
"

"
" ### Gdoc
"
" Task command -> :Gdoc <page>
"
" Open a given grunt doc page in default browser
" borrowed to vim-rails
"
function! s:GDoc(bang, page)
  let url = 'https://github.com/cowboy/grunt/blob/master/docs/'.a:page.'.md'
  echo '... Opening ' . url . ' ...'
  if exists(':OpenURL')
    exe 'OpenURL '.url
  else
    return s:error('No :OpenURL command found')
  endif
endfunction

"
" ### Gtask
"
" Task command -> :Gtask <task>
"
" Usage:
"
"     :Gtask tasks/foo.js
"
" Works best with completion, :Gtask <tab> should return any .js or
" .coffee files under `tasks/`
"
" If the given `task` doesn't exist yet, then a predefined task template
" is loaded into a new buffer.
"
" todo:ensure we always open a new buffer (or reuse opened buffer if
" task already in buffer list)
"
function! s:GTask(bang, args)
  let filename = split(a:args)[0]
  let ext = fnamemodify(filename, ':e') != ""
  " append .js if filename is given without extension
  " and prepend ./tasks/ dir if not already
  let ispath = match(filename, '\/') != -1
  let filename = ispath ? filename : join(['tasks', filename], '/')
  if !ext
    let filename = filename.'.js'
  endif

  let task = join([s:cwd, filename], '/')
  let readable = filereadable(task)

  exe "edit" task
  if !readable
    call s:load_template('task.js', task)
  endif
endfunction

"
" ### Glint
"
" Task command -> :Glint
"
" grunt lint wrapper, collect output for quickfix window. You can then
" jump to the given file, at the given line number
"
" See :h quickfix
"
" > In the quickfix window, each line is one error.  The line number is equal to
" > the error number.  You can use ":.cc" to jump to the error under the cursor.
" > Hitting the <Enter> key or double-clicking the mouse on a line has the same
" > effect.  The file containing the error is opened in the window above the
" > quickfix window.  If there already is a window for that file, it is used
"
" should it use :make and set makeprg instead?
function! s:GLint()
  let cmd='grunt --no-color lint'
  let output = system(cmd)

  let spliterror = 'Linting\|<WARN>'
  let splitname = '[^ ]*\.coffee\|[^ ]*\.js'
  let splitline = '\v\[L(\d*)\:C(\d*)\]\s*([^\n]+)\n'
  let hasError = s:QuickFix(output, spliterror, splitname, splitline)

  call s:LintAutoCmd(hasError)
endfunction

"
" ### Gtest
"
" Task command -> :Gtest [<filename>]
"
" Same as :Glint, runs `grunt test` task, collect output and display any
" error, with filename and error line in the quickfix window.
"
" Except if a filename argument is given, in which case the file is loaded in
" current buffer. Limited amount of completion, globing any files in test/
" dir, should be supported.
"
" todo: grunt test seems to always have coloured output. open issue.
"
function! s:GTest(bang, filename)
  " load file if command was called with arguments
  if a:filename != ""
    exe 'edit ' . a:filename
    if !filereadable(a:filename)
      call s:load_template('test.js', a:filename)
    endif

    return
  endif

  " otherwise run test, and attempt to parse error output
  " note: --no-color with test task seems to have no effect
  let script = join([s:dirname, 'scripts', 'grunt-help.js'], '/')
  let entries = s:NodeQuickFix(system('grunt --no-color test'), script)

  let qflist = []
  for entry in entries
    let errors = entry.errors
    for error in errors
      let msg = error.message . ' ' . error.error
      " find file by globing the task dir, grunt output only include basename
      let name = pathogen#glob('test/**/'. entry.name)
      if empty(name)
        continue
      endif
      :call s:QuickFixAdd(qflist, name[0], error.line, msg)
    endfor
  endfor

  " update the qflist with action set to 'r'
  call setqflist(qflist, 'r')

  " close / open quickfix window depending on errors length
  let hasError = !empty(qflist)
  exe (hasError ? 'copen' : 'cclose')

  call s:TestAutoCmd(hasError)
endfunction

" node variant quickfix helper, mainly for parsing grunt test output
" a bit too tricky for me in plain vimscript
function! s:NodeQuickFix(output, script)
  " should return something
  let json = system('node '.a:script, a:output)
  return parsejson#ParseJSON(json).errors
endfunction


"
" ## Initialization
"

" detect a grunt project, a little crude right now, just checking cwd's
" gruntfile exists todo: it shoulld detect on both cwd (when starting
" vim from console) and actual vim path (eg. vim ./some/nested/path) to
" handle both case
"
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

" redefine gruntlint autocmd group
" this removes any previously defined cmd in this group, and readd
" quickfix window update on save only if there's error.
function s:LintAutoCmd(hasError)
  " redefine gruntlint autocmd group
  " this removes any previously defined cmd in this group, and readd
  " quickfix window update on save only if there's error.
  augroup gruntwritepost
    autocmd!
    if a:hasError
      au BufWritePost *.js call s:GLint()
    endif
  augroup END
endfunction

" same but for GTest
function s:TestAutoCmd(hasError)
  augroup gruntwritepost
    autocmd!
    if a:hasError
      au BufWritePost *.js call s:GTest(0, '')
    endif
  augroup END
endfunction


" Grunt init
function! s:GruntInit()
  " narrow the path for easier find
  call s:SetBasePath()
  " setup openURL command
  call s:initOpenURL()
  " grunt-project commands
  call s:GruntCommands()
  " grunt-project specific gf extension
  call s:InitFind()
endfunction

" define commands loaded only on GruntDetect
function! s:GruntCommands()
  command! -bar -bang -nargs=* -complete=customlist,s:Complete_task Gtask call s:GTask(<bang>0,<q-args>)
  command! -bar -nargs=* -bang -complete=customlist,s:Complete_test Gtest call s:GTest(<bang>0, <q-args>)
  command! -bar -nargs=1 -bang -complete=customlist,s:Complete_docs Gdoc  call s:GDoc(<bang>0,<q-args>)

  " should complete lint and test for subtargets, probably by parsing the gruntfile =/
  command! -bar -nargs=* -bang Glint call s:GLint()
endfunction

augroup gruntdetect
  autocmd!
  autocmd VimEnter * call s:Detect()
augroup END

command! -bar -bang -nargs=* Grunt call s:Grunt(<bang>0,<q-args>)


" vim:set sw=2 sts=2:
