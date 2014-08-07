vim-mconv
=========

[![Build Status](https://travis-ci.org/syngan/vim-mconv.svg?branch=master)](https://travis-ci.org/syngan/vim-mconv)

```vim
echo mconv#calc("(2 + 3) * 4 + 5 * 6")
" 50
echo mconv#calc("add(1, 2, 3)")
" 6
```

```vim
echo mconv#in2pre("(2 + 3) * 4 + 5 * 6")
" (+ (* (+ 2 3) 4) (* 5 6))
```
