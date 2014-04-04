filetype plugin on
runtime! plugin/operator/furround.vim

describe 'in2pre'
  before
    new
  end

  after
    close!
  end

  it '+-'
    Expect mconv#in2pre("1+2") ==# "(+ 1 2)"
    Expect mconv#in2pre("1 + 2") ==# "(+ 1 2)"
    Expect mconv#in2pre("1-2") ==# "(- 1 2)"
    Expect mconv#in2pre("1 - 2") ==# "(- 1 2)"
    Expect mconv#in2pre("1 + 2 - 3") ==# "(- (+ 1 2) 3)"
  end

  it '*/'
    Expect mconv#in2pre("1*2") ==# "(* 1 2)"
    Expect mconv#in2pre("1 * 2") ==# "(* 1 2)"
    Expect mconv#in2pre("1/2") ==# "(/ 1 2)"
    Expect mconv#in2pre("1 / 2") ==# "(/ 1 2)"
    Expect mconv#in2pre("1 * 2 / 3") ==# "(/ (* 1 2) 3)"
  end

  it '^'
    Expect mconv#in2pre("1^2") ==# "(^ 1 2)"
    Expect mconv#in2pre("1 ^ 2") ==# "(^ 1 2)"
  end

  it '-'
    Expect mconv#in2pre("-2") ==# "(- 2)"
  end

  it '()'
    Expect mconv#in2pre("1 + 2 * 3") ==# "(+ 1 (* 2 3))"
    Expect mconv#in2pre("1 + (2 * 3)") ==# "(+ 1 (* 2 3))"
    Expect mconv#in2pre("(1 + 2) * 3") ==# "(* (+ 1 2) 3)"
  end
end


" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
