scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" ■■
" expression :: expr (=)\=
" expr :: term \( "+" term | "-" term \)\+
" term :: factor \( "*" factor | "/" factor \) \+
" factor ::  unary \( "^" unary \)
" unary :: "+" unary | "-" unary | primary
" primary :: "(" expression ")" | num | name | func
" func :: name '(' arglist ')' | name '(' ')'

let s:obj = {}

" func :: name '(' arglist ')' | name '(' ')'
function! s:obj.func(name) " {{{
  call self.consume()
  call self.ignore()
  let ret = '(' . a:name
  while !self.next_is(')')
    let ret .= ' ' . self.expr()
    call self.ignore()
    if self.next_is(')')
      break
    endif
    if self.next_is(',')
      call self.consume()
    else
      throw 'syntax error. missing '')'''
    endif
  endwhile

  call self.consume()
  return ret . ')'
endfunction " }}}

" primary :: "(" expression ")" | num | name
function! s:obj.primary() dict " {{{
  call self.ignore()
  if self.next_is('name')
    let text = self.consume().matched_text
    call self.ignore()
    if !self.next_is('(')
      return text
    else
      return self.func(text)
    endif
  elseif self.next_is('num')
    return self.consume().matched_text
  elseif self.next_is('(')
    call self.consume()
    call self.ignore()
    let o = self.expr()
    call self.ignore()
    if !self.next_is([')'])
      throw 'syntax error. missing '')'''
    endif
    call self.consume()
    return o
  else
    throw 'syntax error'
  endif
endfunction " }}}

" unary :: "+" unary | "-" unary | primary
function! s:obj.unary() dict " {{{
  if self.next_is('+')
    call self.consume()
    call self.ignore()
    return self.primary()
  elseif self.next_is('-')
    call self.consume()
    call self.ignore()
    return "(- " . self.primary() . ")"
  else
    return self.primary()
  endif
endfunction " }}}

" factor ::  unary \( "^" unary \)
function! s:obj.factor() dict " {{{
  let lhs = self.unary()
  if !self.end()
    call self.ignore()
    if self.next_is('^')
      call self.consume()
      let lhs = "(^ " . lhs . " " . self.unary() . ")"
    endif
  endif
  return lhs
endfunction " }}}

function! s:obj.term() dict " {{{
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
endfunction " }}}

function! s:obj.expr() dict " {{{
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
endfunction " }}}

function! s:obj.expression() dict " {{{
  let lhs = self.expr()
  if ! self.end()
    call self.ignore()
    if ! self.next_is(['='])
      throw 'syntax error. missing ''='''
    endif
    call self.consume()
  endif
  return lhs
endfunction " }}}

function! mconv#in2pre#get() " {{{
  return s:obj
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
