function vertfind#ColPattern(pattern)
  let column = winsaveview().curswant + 1
  if column < 0
    return a:pattern . '\_$'
  endif
  return '\%<' . (column + 1) . 'v' . a:pattern . '\%>' . column . 'v'
endfunction

function vertfind#Pattern(pattern, flags)
  if type(a:pattern) == type([])
    let ret = a:flags =~# 'b' ? '\_$' : '^'
    let i = 0
    while i < len(a:pattern)
      if type(a:pattern[i]) == type([])
	let pat = a:pattern[i][1]
	let cmp = a:pattern[i][0] =~ '!' ? '!' : '='
      else
	let pat = a:pattern[i]
	let cmp = '='
      endif
      let pat = vertfind#ColPattern(pat)
      if i == 0 && cmp == '='
	let ret = pat
      else
	let brs = '.*\(\n.*\)\{' . i . '}'
	if a:flags =~# 'b'
	  let ret .= '\(' . pat . brs . '\)\@<' . cmp
	else
	  let ret .= '\(' . brs . pat . '\)\@' . cmp
	endif
      endif
      let i += 1
    endwhile
    return ret
  endif
  return vertfind#ColPattern(a:pattern)
endfunction

function vertfind#FindPattern(pattern, flags)
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

function vertfind#Find(pattern, flags)
  return vertfind#FindPattern(vertfind#Pattern(a:pattern, a:flags), a:flags)
endfunction
