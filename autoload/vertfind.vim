function vertfind#VertColPattern(pattern)
  let column = winsaveview().curswant + 1
  if column < 0
    return a:pattern . '\($\)'
  endif
  return '\%<' . (column + 1) . 'v' . a:pattern . '\%>' . column . 'v'
endfunction

function vertfind#VertFindPattern(pattern, flags)
  let line = search(a:pattern, a:flags . 'nW')
  if line == 0
    return "\<Plug>"	" bell in noremap
  endif
  let relative = line - line(".")
  if relative < 0
    return -relative . 'k'
  elseif relative > 0
    return  relative . 'j'
  else
    return ''
  endif
endfunction

function vertfind#VertFind(pattern, flags)
  return vertfind#VertFindPattern(vertfind#VertColPattern(a:pattern), a:flags)
endfunction
