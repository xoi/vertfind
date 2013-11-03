function vertfind#ColPattern(pattern)
  let column = winsaveview().curswant + 1
  if column < 0
    return a:pattern . '\_$'
  endif
  return '\%<' . (column + 1) . 'v' . a:pattern . '\%>' . column . 'v'
endfunction

function vertfind#Pattern(pattern, flags)
  if type(a:pattern) == type([])
    " find anchor
    let anchor = 0
    let i = 0
    while i < len(a:pattern)
      if type(a:pattern[i]) == type([])
	let flg = a:pattern[i][0]
	if flg =~ '<'
	  let anchor = i + 1
	  break
	endif
      endif
      let i += 1
    endwhile
    " make pattern
    let ret = ''
    let i = 0
    while i < len(a:pattern)
      if type(a:pattern[i]) == type([])
	let pat = a:pattern[i][1]
	let flg = a:pattern[i][0]
	let cmp = flg =~ '!' ? '!' : '='
	if flg =~# 'q'
	  let pat = '\V' . escape(pat, '\') . '\m'
	endif
      else
	let pat = a:pattern[i]
	let cmp = '='
      endif
      let pat = vertfind#ColPattern(pat)
      if i == anchor && cmp == '!'
	let ret_anchor = a:flags =~# 'b' ? '\_$' : '^'
      endif
      if i == anchor && cmp == '='
	let ret_anchor = pat
      else
	let brs = '.*\(\n.*\)\{' . (i - anchor) . '}'
	if (a:flags =~# 'b') != (i < anchor)
	  let ret .= '\(' . pat . brs . '\)\@<' . cmp
	else
	  let ret .= '\(' . brs . pat . '\)\@' . cmp
	endif
      endif
      let i += 1
    endwhile
    return ret_anchor . ret
  endif
  return vertfind#ColPattern(a:pattern)
endfunction

function s:rhs(line)
  let rhs = v:count ? repeat("\<Del>", len(v:count)) : ''	" clear count
  " vertical motion
  let relative = a:line - line('.')
  if relative < 0
    let rhs .= -relative . 'k'
  elseif relative > 0
    let rhs .=  relative . 'j'
  endif
  return rhs
endfunction

function vertfind#FindPattern(pattern, flags)
  try
    let view = winsaveview()
    let i = 0
    while i < v:count1
      let line = search('\C\m' . a:pattern, a:flags . 'W')
      if line == 0
	return "\<Plug>"	" bell in noremap
      endif
      let i += 1
    endwhile
  finally
    call winrestview(view)	" map-<expr> does not restore curswant
  endtry
  return s:rhs(line)
endfunction

function vertfind#Find(pattern, ...)
  let flags = a:0 < 1 ? '' : a:1
  return vertfind#FindPattern(vertfind#Pattern(a:pattern, flags), flags)
endfunction

function vertfind#SmartFind(...)
  let flags = a:0 < 1 ? '' : a:1
  let dir = flags =~# 'b' ? -1 : 1
  let col_pat = vertfind#ColPattern('.')
  let cursor_char = []
  let lnum = line('.')
  let i = 0
  while i < 3
    call add(cursor_char, matchstr(getline(lnum), col_pat))
    let lnum += dir
    let i += 1
  endwhile
  if cursor_char[0] =~ '\S' && (cursor_char[1] !~ '\S' || cursor_char[2] !~ '\S')
    let pat = [['<!', '\S'], '\S']
  elseif cursor_char[1] =~ '\s' && cursor_char[2] =~ '\s'
    let pat = ['\s', ['!', '\s']]
  elseif cursor_char[1] == '' && cursor_char[2] == ''
    let pat = [['!', '.'], '.']
  elseif cursor_char[1] ==# cursor_char[2]
    let pat = [['q', cursor_char[1]], ['!q', cursor_char[1]]]
  elseif cursor_char[1] !~ '\S' && cursor_char[2] !~ '\S'
    let pat = [['!', '\S'], '\S']
  elseif cursor_char[1] !~ '\S'
    let pat = [['<!', '\S'], '\S']
  elseif cursor_char[2] =~ '\s'
    let pat = ['.', ['!', '.']]
  elseif cursor_char[2] == ''
    let pat = [['!', '\s'], '\s']
  else
    let pat = ['\S', ['!', '\S']]
  endif
  let ret = vertfind#Find(pat, flags)
  if ret == "\<Plug>"	" not found
    " find edge of file
    let line = dir < 0 ? 1 : line('$')
    if line != line('.')
      return s:rhs(line)
    endif
  endif
  return ret
endfunction
