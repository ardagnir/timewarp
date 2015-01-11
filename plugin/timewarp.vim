" Timewarp
" Retroactive vim macros and improved dot operator
"
" Copyright (C) 2014, James Kolb <jck1089@gmail.com>
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU Affero General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
" 
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU Affero General Public License for more details.
" 
" You should have received a copy of the GNU Affero General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.

let g:save_cpo = &cpo
set cpo&vim
if exists("g:loaded_timewarp")
  finish
endif

autocmd!
autocmd CursorMoved * call RecordText()
autocmd TextChanged * call TextChanged()
autocmd TextChangedI * call TextChangedI()
nnoremap . :call CallDot()<CR>
nnoremap <Plug>. :call EndDot()<CR>
nnoremap <Left> :call StepToTheLeft()<CR>
nnoremap <Right> :call StepToTheRight()<CR>
nnoremap <Up> :call JumpToTheLeft()<CR>
nnoremap <Down> :call JumpToTheRight()<CR>

let g:dotLeft = 0
let g:dotRight = 0
let g:dotting = 0
let g:changeList = []
let g:commandList = []
normal! qt

function! RecordText()
  "TODO: save t register
  normal! q
  if @t != ""
    let g:commandList += [@t]
  endif
  normal! qt
  "TODO: retore t register
endfunction

function! TextChangedI()
  if len(g:changeList) == 0 || g:changeList[-1] != len(g:commandList)
    let g:changeList += [len(g:commandList)]
    if g:dotting == 0
      let g:dotLeft = len(g:changeList) - 1
      let g:dotRight = len(g:changeList) - 1
    endif
  endif
endfunction

function! TextChanged()
  if g:commandList[len(g:commandList)-1] != "u" "TODO: Also filter out U, g-, g+, etc
    if len(g:changeList) == 0 || g:changeList[-1] != len(g:commandList) - 1
      let g:changeList += [len(g:commandList) - 1]
      if g:dotting == 0
        let g:dotLeft = len(g:changeList) - 1
        let g:dotRight = len(g:changeList) - 1
      endif
    endif
  endif
endfunction

function! CallDot()
  let g:dotting = 1
  normal! q
  for command in range(g:changeList[g:dotLeft], g:changeList[g:dotRight])
    call feedkeys(g:commandList[command], 't')
  endfor
  call feedkeys("\<Plug>.", 't')
  normal! qt
endfunction

function! EndDot()
  let g:dotting = 0
endfunction

function! Undot()
  let g:dotting = 1
  for undoer in range(g:dotLeft, g:dotRight)
    call feedkeys("u", 't')
  endfor
endfunction

function! JumpToTheLeft()
  call Undot()
  let g:dotLeft -= 1
  let g:dotRight -= 1
  call CallDot()
endfunction

function! JumpToTheRight()
  call Undot()
  let g:dotLeft += 1
  let g:dotRight += 1
  call CallDot()
endfunction

function! StepToTheLeft()
  call Undot()
  let g:dotLeft -= 1
  call CallDot()
endfunction

function! StepToTheRight()
  call Undot()
  let g:dotLeft += 1
  call CallDot()
endfunction

let g:loaded_timewarp = 1

let &cpo = g:save_cpo
unlet g:save_cpo
