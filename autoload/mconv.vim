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
\ [',', ','],
\ ['=', '='],
\ ['ws', '\s\+'],
\])

function! mconv#in2pre(s) " {{{
  let p = s:P.parser().exec(s:lexer.exec(a:s))
  let p = extend(p, mconv#in2pre#get(), "keep")
  call p.config({ 'ignore_labels' : ['ws'] })
  return p.expression()
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
