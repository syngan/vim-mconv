filetype plugin on

describe 'calc'
  before
    new
  end

  after
    close!
  end

  it '+-'
    Expect mconv#calc("1+2") == 3
    Expect mconv#calc("1 + 2") == 3
    Expect mconv#calc("1-2") == -1
    Expect mconv#calc("1 - 2") == -1
    Expect mconv#calc("1 + 2 - 3") == 0
    Expect mconv#calc("1 + 2 + 3") == 6
  end

  it '*/'
    Expect mconv#calc("3*2") == 6
    Expect mconv#calc("3 * 2") == 6
    Expect mconv#calc("3.0/2") == 1.5
    Expect mconv#calc("3 / 2") == 1
    Expect mconv#calc("3 * 2 / 3") ==# 2
  end

  it '^'
    Expect mconv#calc("2^0") == 1
    Expect mconv#calc("2^1") == 2
    Expect mconv#calc("2^2") == 4
    Expect mconv#calc("2^3") == 8
    Expect mconv#calc("2^4") == 16
    Expect mconv#calc("2^5") == 32
    Expect mconv#calc("2^6") == 64
    Expect mconv#calc("2^7") == 128
    Expect mconv#calc("2^8") == 256
    Expect mconv#calc("2^9") == 512
    Expect mconv#calc("2^10") == 1024
  end

  it '-'
    Expect mconv#calc("-2") == -2
    Expect mconv#calc("+3") == 3
    Expect mconv#calc("4.1") == 4.1
  end

  it 'priority'
    Expect mconv#calc("2 + 3 * 4") == 14
    Expect mconv#calc("2 * 3 + 4") == 10
    Expect mconv#calc("2 - 3 * 4") == -10
    Expect mconv#calc("2 * 3 - 4") == 2
    Expect mconv#calc("2 + 3 ^ 4") == 83
    Expect mconv#calc("2 ^ 3 + 4") == 12
    Expect mconv#calc("2 - 3 ^ 4") == -79
    Expect mconv#calc("2 ^ 3 - 4") == 4
    Expect mconv#calc("2 * 3 ^ 4") == 162
    Expect mconv#calc("2 ^ 3 * 4") == 32
  end

  it '()'
    Expect mconv#calc("1 + 2 * 3") == 7
    Expect mconv#calc("1 + (2 * 3)") == 7
    Expect mconv#calc("(1 + 2) * 3") == 9
  end

  it 'add'
    Expect mconv#calc("add(4,5,6)") == 15
    Expect mconv#calc("add(4,,5,,6,,,)") == 15
  end

end


" vim:set et ts=2 sts=2 sw=2 tw=0:
