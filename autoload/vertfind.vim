function vertfind#VertColPattern(pattern)
  let column = winsaveview().curswant + 1
  if column < 0
    return a:pattern . '\($\)'
  endif
  return '\%<' . (column + 1) . 'v' . a:pattern . '\%>' . column . 'v'
endfunction

function vertfind#VertFindPattern(pattern, flags)
  try
    let view = winsaveview()
    let i = 0
    while i < v:count1
      let line = search('\C' . a:pattern, a:flags . 'W')
      if line == 0
	return "\<Plug>"	" bell in noremap
      endif
      let i += 1
    endwhile
  finally
    call winrestview(view)	" map-<expr> does not restore curswant
  endtry
  let rhs = v:count ? repeat("\<Del>", len(v:count)) : ''	" clear count
  let relative = line - view.lnum
  if relative < 0
    let rhs .= -relative . 'k'
  elseif relative > 0
    let rhs .=  relative . 'j'
  endif
  return rhs
endfunction

function vertfind#VertFind(pattern, flags)
  return vertfind#VertFindPattern(vertfind#VertColPattern(a:pattern), a:flags)
endfunction
