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

let s:funcs = {}

function! s:funcs.add(args) " {{{
  let ret = 0
  for a in a:args
    let ret += a
  endfor
  return ret
endfunction " }}}

function! s:funcs.mean(args) " {{{
  let sum = s:funcs.add(a:args)
  return sum / len(a:args)
endfunction " }}}

" func :: name '(' arglist ')' | name '(' ')'
function! s:obj.func(name) " {{{
  call self.consume()
  call self.ignore()

  if ! has_key(s:funcs, a:name)
    throw 'unknown function: ' . a:name
  endif

  let args = []
  while !self.next_is(')')
    call self.ignore()
    if self.next_is(',')
      call self.consume()
      continue
    endif
    if self.next_is(')')
      break
    endif

    call add(args, self.expr())
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

  return s:funcs[a:name](args)
endfunction " }}}

" primary :: "(" expression ")" | num | name
function! s:obj.primary() dict " {{{
  call self.ignore()
  if self.next_is('name')
    let text = self.consume().matched_text
    call self.ignore()
    if !self.next_is('(')
      throw 'syntax error. missing ''('''
    else
      return self.func(text)
    endif
  elseif self.next_is('num')
    let num = self.consume().matched_text
    if ! self.next_is('dot')
      return str2nr(num)
    endif
    call self.consume()
    if ! self.next_is('num')
      throw 'syntax error. unexpected ''.'''
    endif

    let num .= '.' . self.consume().matched_text
    return str2float(num)

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
    return  -self.primary()
  else
    return self.primary()
  endif
endfunction " }}}

function! s:npow(u, e) " {{{
  let t = a:u
  let e = a:e
  let w = 1
  while 1
    if and(e, 1)
      let w = w * t
    endif
    let e = e / 2
    if e == 0
      return w
    endif
    let t = t * t
  endwhile
endfunction " }}}

" factor ::  unary \( "^" unary \)
function! s:obj.factor() dict " {{{
  let lhs = self.unary()
  if !self.end()
    call self.ignore()
    if self.next_is('^')
      call self.consume()
      let rhs = self.unary()
      if type(rhs) != type(1)
        throw 'syntax error. unsupported ''^'''
      endif

      if rhs < 0
        let rhs = -rhs
        let lhs = 1 / lhs
      endif

      if type(lhs) == type(0) && type(rhs) == type(0)
        let lhs = s:npow(lhs, rhs)
      else
        let lhs = pow(lhs, rhs)
      endif
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
      if op.label == '*'
        let lhs = lhs * self.factor()
      else
        let lhs = lhs / self.factor()
      endif
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
      if op.label == '+'
        let lhs += self.term()
      else
        let lhs -= self.term()
      endif
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
      echo self.consume()
      throw 'syntax error. missing ''='''
    endif
    call self.consume()
  endif
  return lhs
endfunction " }}}

function! mconv#calc#get() " {{{
  return s:obj
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
