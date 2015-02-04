scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" expression (op arg1 arg2 arg3)

let s:obj = {}

function! s:wrap(a) " {{{
  if type(a:a) == type(1) && a:a >= 0
    return a:a
  elseif a:a =~ '^[A-Za-z0-9_]\+$'
    return a:a
  elseif a:a[0] == '('
    return a:a
  else
    return '(' . a:a . ')'
  endif
endfunction " }}}

function! s:obj.expression() dict " {{{
  call self.ignore()
  if ! self.next_is(['('])
    if self.next_is('num')
      let a = self.consume().matched_text
      return str2nr(a)
    else
      return self.consume().matched_text
    endif
  endif

  let a = []
  call self.consume()
  while ! self.end()
    if self.next_is([')'])
      break
    endif
    let a += [self.expression()]
    call self.ignore()
  endwhile
  if !self.next_is([')'])
    throw 'syntax error. missing ''('''
  endif
  call self.consume()
  if len(a) == 0
    throw 'arg'
  endif

  if a[0] == '-' && len(a) == 2
    return type(a[1]) == type(0) ? -a[1] : '-' . s:wrap(a[1])
  endif

  if a[0] == '+' || a[0] == '-' || a[0] == '*' || a[0] == '/'
    if len(a) <= 2
      throw 'arg'
    endif
    if a[0] == '*'
      for i in range(1, len(a)-1)
        if a[i] is 0
          return 0
        endif
      endfor
    endif
    if a[0] == '+' || a[0] == '-'
      let skip = 0
    elseif a[0] == '*' || a[0] == '/'
      let skip = 1
    else
      let skip = ""
    endif

    " 複数の数値がある場合は演算してしまう.


    for i in range(1, len(a)-1)
      if a[i] isnot skip
        break
      endif
    endfor
    if i >= len(a)
      return skip
    endif

    if a[0] != '/'
      let hasnum = -1
      for c in range(i, len(a)-1)
        if type(a[c]) == type(0)
          if hasnum < 0
            let hasnum = c
          elseif a[0] == '+'
            let a[hasnum] += a[c]
            let a[c] = skip
          elseif a[0] == '-'
            let a[hasnum] -= a[c]
            let a[c] = skip
          elseif a[0] == '*'
            let a[hasnum] = a[hasnum] * a[c]
            let a[c] = skip
          endif
        endif
      endfor
    endif


    let str = s:wrap(a[i])
    for i in range(i+1, len(a)-1)
      if a[i] isnot skip
        let str = str . a[0] . s:wrap(a[i])
      endif
    endfor

    return str
  elseif a[0] == '=' || a[0] == '<' || a[0] == '>' || a[0] == '<=' || a[0] == '>='
    if len(a) != 3
      throw 'argnum op=' . a[0] . ', num=' . len(a)
    endif

    return s:wrap(a[1]) .  a[0] . s:wrap(a[2])
  endif

  throw "unknown"
endfunction " }}}

function! mconv#pre2in#get() " {{{
  return s:obj
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
