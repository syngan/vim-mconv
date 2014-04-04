scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('mconv')
let s:L = s:V.import('Text.Lexer')
let s:P = s:V.import('Text.Parser')

let s:lexer = s:L.lexer([
\ ['num', '\d\+'],
\ ['name', '[A-Za-z0-9_]\+'],
\ ['+', '+'],
\ ['-', '-'],
\ ['*', '*'],
\ ['/', '/'],
\ ['^', '\^'],
\ ['(', '('],
\ [')', ')'],
\ ['ws', '\s\+'],
\])

" ■■■
" expression :: term \( "+" term | "-" term \)\+
" term :: factor \( "*" factor | "/" factor \) \+
" factor ::  unary \( "^" unary \)
" unary :: "+" unary | "-" unary | primary
" primary :: "(" expression ")" | num | name

let s:obj = {}
" primary :: "(" expression ")" | num | name
function! s:obj.primary() dict
  call self.ignore()
  if self.next_is(['num']) || self.next_is(['name'])
    return self.consume().matched_text
  elseif self.next_is('(')
    call self.consume()
    call self.ignore()
    let o = self.expression()
    call self.ignore()
    if !self.next_is([')'])
      throw 'syntax error. missing '')'''
    endif
    call self.consume()
    return o
  else
    throw 'syntax error'
  endif
endfunction

" unary :: "+" unary | "-" unary | primary
function! s:obj.unary() dict
  if self.next_is(['+'])
    call self.consume()
    call self.ignore()
    return self.primary()
  elseif self.next_is(['-'])
    call self.consume()
    call self.ignore()
    return "(- " . self.primary() . ")"
  else
    return self.primary()
  endif
endfunction

" factor ::  unary \( "^" unary \)
function! s:obj.factor() dict
  let lhs = self.unary()
  if !self.end()
    call self.ignore()
    if self.next_is('^')
      call self.consume()
      let lhs = "(^ " . lhs . " " . self.unary() . ")"
    endif
  endif
  return lhs
endfunction

function! s:obj.term() dict
  let lhs = self.factor()
  while ! self.end()
    call self.ignore()
    if self.next_is(['*']) || self.next_is(['/'])
      let op = self.consume()
      let lhs = "(" . op.label . " " . lhs . " " . self.factor() . ")"
    else
      break
    endif
  endwhile
  return lhs
endfunction

function! s:obj.expression() dict
  let lhs = self.term()
  while ! self.end()
    call self.ignore()
    if self.next_is(['+']) || self.next_is(['-'])
      let op = self.consume()
      let lhs = "(" . op.label . " " . lhs . " " . self.term() . ")"
    else
      break
    endif
  endwhile
  return lhs
endfunction

function! mconv#in2pre(s)
  let p = s:P.parser().exec(s:lexer.exec(a:s))
  let p = extend(p, s:obj, "keep")
  call p.config({ 'ignore_labels' : ['ws'] })
  return p.expression()
endfunction

function! mconv#in2pre_line()
  let s = getline(".")
  call setline(".", mconv#in2pre(s))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
