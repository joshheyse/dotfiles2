" MIT License. Copyright (c) 2013-2021 Bailey Ling Christian Brabandt et al.
" vim: et ts=2 sts=2 sw=2

scriptencoding utf-8

let s:is_win32term = (has('win32') || has('win64')) &&
                   \ !has('gui_running') &&
                   \ (empty($CONEMUBUILD) || &term !=? 'xterm') &&
                   \ empty($WT_SESSION) &&
                   \ !(exists("+termguicolors") && &termguicolors)

let s:separators = {}
let s:accents = {}

" basic 16 msdos from MSDOS
" see output of color, should be
"     0    Black
"     1    DarkBlue
"     2    DarkGreen
"     3    DarkCyan
"     4    DarkRed
"     5    DarkMagenta
"     6    Brown
"     7    LightGray
"     8    DarkGray
"     9    Blue
"     10   Green
"     11   Cyan
"     12   Red
"     13   Magenta
"     14   Yellow
"     15   White

let s:basic16 = [
  \ [ 0x00, 0x00, 0x00 ],
  \ [ 0x00, 0x00, 0x80 ],
  \ [ 0x00, 0x80, 0x00 ],
  \ [ 0x00, 0x80, 0x80 ],
  \ [ 0x80, 0x00, 0x00 ],
  \ [ 0x80, 0x00, 0x80 ],
  \ [ 0x80, 0x80, 0x00 ],
  \ [ 0xC0, 0xC0, 0xC0 ],
  \ [ 0x80, 0x80, 0x80 ],
  \ [ 0x00, 0x00, 0xFF ],
  \ [ 0x00, 0xFF, 0x00 ],
  \ [ 0x00, 0xFF, 0xFF ],
  \ [ 0xFF, 0x00, 0x00 ],
  \ [ 0xFF, 0x00, 0xFF ],
  \ [ 0xFF, 0xFF, 0x00 ],
  \ [ 0xFF, 0xFF, 0xFF ]
  \ ]

function! colorutils#SynGroup()
  let l:s = synID(line('.'), col('.'), 1)
  echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun

function! colorutils#round_msdos_colors(rgblist)
  " Check for values from MSDOS 16 color terminal
  let best = []
  let min  = 100000
  let list = s:basic16
  for value in list
    let t = abs(value[0] - a:rgblist[0]) +
          \ abs(value[1] - a:rgblist[1]) +
          \ abs(value[2] - a:rgblist[2])
    if min > t
      let min = t
      let best = value
    endif
  endfor
  return index(s:basic16, best)
endfunction

function! colorutils#gui2cui(rgb, fallback) abort
  if a:rgb == ''
    return a:fallback
  elseif match(a:rgb, '^\%(NONE\|[fb]g\)$') > -1
    return a:rgb
  endif
  let rgb = map(split(a:rgb[1:], '..\zs'), '0 + ("0x".v:val)')
  return colorutils#round_msdos_colors(rgb)
endfunction

function! colorutils#get_syn(group, what, mode) abort
  let color = ''
  if hlexists(a:group)
    let color = synIDattr(synIDtrans(hlID(a:group)), a:what, a:mode)
  endif
  if empty(color) || color == -1
    " should always exist
    let color = synIDattr(synIDtrans(hlID('Normal')), a:what, a:mode)
    " however, just in case
    if empty(color) || color == -1
      let color = 'NONE'
    endif
  endif
  return color
endfunction

function! colorutils#get_array(guifg, guibg, ctermfg, ctermbg, opts) abort
  return [ a:guifg, a:guibg, a:ctermfg, a:ctermbg, empty(a:opts) ? '' : join(a:opts, ',') ]
endfunction

function! colorutils#get_highlight(group, ...) abort
  " only check for the cterm reverse attribute
  " TODO: do we need to check all modes (gui, term, as well)?
  let reverse = synIDattr(synIDtrans(hlID(a:group)), 'reverse', 'cterm')
  let ctermfg = colorutils#get_syn(a:group, 'fg', 'cterm')
  let ctermbg = colorutils#get_syn(a:group, 'bg', 'cterm')
  let guifg = colorutils#get_syn(a:group, 'fg', 'gui')
  let guibg = colorutils#get_syn(a:group, 'bg', 'gui')
  let bold = synIDattr(synIDtrans(hlID(a:group)), 'bold')
  if reverse
    let res = colorutils#get_array(guibg, guifg, ctermbg, ctermfg, bold ? ['bold'] : a:000)
  else
    let res = colorutils#get_array(guifg, guibg, ctermfg, ctermbg, bold ? ['bold'] : a:000)
  endif
  return res
endfunction

function! colorutils#get_highlight2(fg, bg, ...) abort
  let guifg = colorutils#get_syn(a:fg[0], a:fg[1], 'gui')
  let guibg = colorutils#get_syn(a:bg[0], a:bg[1], 'gui')
  let ctermfg = colorutils#get_syn(a:fg[0], a:fg[1], 'cterm')
  let ctermbg = colorutils#get_syn(a:bg[0], a:bg[1], 'cterm')
  return colorutils#get_array(guifg, guibg, ctermfg, ctermbg, a:000)
endfunction

function! colorutils#hl_group_exists(group) abort
  if !hlexists(a:group)
    return 0
  elseif empty(synIDattr(hlID(a:group), 'fg'))
    return 0
  endif
  return 1
endfunction

function! colorutils#set_highlight(group, colors) abort
    let cmd = printf('hi %s%s', a:group, colorutils#GetHiCmd(a:colors))
    exe cmd
endfunction

function! colorutils#exec(group, colors) abort
  if pumvisible()
    return
  endif
  let colors = a:colors
  if s:is_win32term
    let colors[2] = colorutils#gui2cui(get(colors, 0, ''), get(colors, 2, ''))
    let colors[3] = colorutils#gui2cui(get(colors, 1, ''), get(colors, 3, ''))
  endif
  let old_hi = colorutils#get_highlight(a:group)
  if len(colors) == 4
    call add(colors, '')
  endif
  let new_hi = [colors[0], colors[1], printf('%s', colors[2]), printf('%s', colors[3]), colors[4]]
  let colors = colorutils#CheckDefined(colors)
  if old_hi != new_hi || !colorutils#hl_group_exists(a:group)
    call colorutils#set_highlight(a:group, colors)
  endif
endfunction

function! colorutils#CheckDefined(colors) abort
  " Checks, whether the definition of the colors is valid and is not empty or NONE
  " e.g. if the colors would expand to this:
  " hi airline_c ctermfg=NONE ctermbg=NONE
  " that means to clear that highlighting group, therefore, fallback to Normal
  " highlighting group for the cterm values

  " This only works, if the Normal highlighting group is actually defined, so
  " return early, if it has been cleared
  if !exists("g:colorutils#normal_fg_hi")
    let g:colorutils#normal_fg_hi = synIDattr(synIDtrans(hlID('Normal')), 'fg', 'cterm')
  endif
  if empty(g:colorutils#normal_fg_hi) || g:colorutils#normal_fg_hi < 0
    return a:colors
  endif

  for val in a:colors
    if !empty(val) && val !=# 'NONE'
      return a:colors
    endif
  endfor
  " this adds the bold attribute to the term argument of the :hi command,
  " but at least this makes sure, the group will be defined
  let fg = g:colorutils#normal_fg_hi
  let bg = synIDattr(synIDtrans(hlID('Normal')), 'bg', 'cterm')
  if bg < 0
    " in case there is no background color defined for Normal
    let bg = a:colors[3]
  endif
  return a:colors[0:1] + [fg, bg] + [a:colors[4]]
endfunction

function! colorutils#GetHiCmd(list) abort
  " a:list needs to have 5 items!
  let res = ''
  let i = -1
  while i < 4
    let i += 1
    let item = get(a:list, i, '')
    if item is ''
      continue
    endif
    if i == 0
      let res .= ' guifg='.item
    elseif i == 1
      let res .= ' guibg='.item
    elseif i == 2
      let res .= ' ctermfg='.item
    elseif i == 3
      let res .= ' ctermbg='.item
    elseif i == 4
      let res .= printf(' gui=%s cterm=%s term=%s', item, item, item)
    endif
  endwhile
  return res
endfunction