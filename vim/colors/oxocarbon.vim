" Oxocarbon Dark (Vim-compatible), using nyoom-engineering/base16-oxocarbon
" Source palette: https://github.com/nyoom-engineering/base16-oxocarbon
set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = 'oxocarbon'

" Palette: bg #161616, fg #f2f4f8, blue #78a9ff, cyan #3ddbd9,
" purple #be95ff, pink #ee5396, green #42be65.
hi Normal       guifg=#f2f4f8 guibg=#161616 ctermfg=255 ctermbg=234
hi NonText      guifg=#525252 guibg=NONE    ctermfg=240 ctermbg=NONE
hi Comment      guifg=#78808a gui=italic    ctermfg=245
hi Constant     guifg=#3ddbd9              ctermfg=80
hi String       guifg=#42be65              ctermfg=71
hi Character    guifg=#42be65              ctermfg=71
hi Number       guifg=#3ddbd9              ctermfg=80
hi Boolean      guifg=#3ddbd9              ctermfg=80
hi Identifier   guifg=#78a9ff              ctermfg=111
hi Function     guifg=#78a9ff              ctermfg=111
hi Statement    guifg=#be95ff              ctermfg=141
hi Conditional  guifg=#be95ff              ctermfg=141
hi Repeat       guifg=#be95ff              ctermfg=141
hi Operator     guifg=#ff7eb6              ctermfg=212
hi Keyword      guifg=#be95ff              ctermfg=141
hi PreProc      guifg=#ee5396              ctermfg=205
hi Type         guifg=#33b1ff              ctermfg=75
hi Special      guifg=#82cfff              ctermfg=117
hi Underlined   guifg=#78a9ff gui=underline ctermfg=111 cterm=underline
hi Error        guifg=#ffffff guibg=#a2191f ctermfg=231 ctermbg=124
hi Todo         guifg=#161616 guibg=#ee5396 ctermfg=234 ctermbg=205
hi LineNr       guifg=#525252 guibg=#161616 ctermfg=240 ctermbg=234
hi CursorLineNr guifg=#78a9ff gui=bold ctermfg=111 cterm=bold
hi CursorLine   guibg=#262626 ctermbg=235
hi ColorColumn  guibg=#262626 ctermbg=235
hi Visual       guibg=#393939 ctermbg=237
hi Search       guifg=#161616 guibg=#78a9ff ctermfg=234 ctermbg=111
hi IncSearch    guifg=#161616 guibg=#3ddbd9 ctermfg=234 ctermbg=80
hi StatusLine   guifg=#f2f4f8 guibg=#393939 ctermfg=255 ctermbg=237
hi StatusLineNC guifg=#dde1e6 guibg=#262626 ctermfg=253 ctermbg=235
hi VertSplit    guifg=#393939 guibg=#161616 ctermfg=237 ctermbg=234
hi Pmenu        guifg=#f2f4f8 guibg=#262626 ctermfg=255 ctermbg=235
hi PmenuSel     guifg=#161616 guibg=#78a9ff ctermfg=234 ctermbg=111
hi Folded       guifg=#82cfff guibg=#262626 ctermfg=117 ctermbg=235
hi Directory    guifg=#78a9ff ctermfg=111
hi DiffAdd      guifg=#42be65 guibg=#262626 ctermfg=71 ctermbg=235
hi DiffChange   guifg=#78a9ff guibg=#262626 ctermfg=111 ctermbg=235
hi DiffDelete   guifg=#ee5396 guibg=#262626 ctermfg=205 ctermbg=235
hi ErrorMsg     guifg=#ee5396 ctermfg=205
hi WarningMsg   guifg=#ff7eb6 ctermfg=212
hi MatchParen   guifg=#ffffff guibg=#525252 gui=bold ctermfg=231 ctermbg=240 cterm=bold
hi SignColumn   guibg=#161616 ctermbg=234
hi TabLine      guifg=#dde1e6 guibg=#262626 ctermfg=253 ctermbg=235
hi TabLineSel   guifg=#ffffff guibg=#393939 gui=bold ctermfg=231 ctermbg=237
