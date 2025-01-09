call plug#begin('~/.config/nvim/plugged')
Plug 'morhetz/gruvbox' "https://github.com/neoclide/coc.nvim/issues/3784
Plug 'sheerun/vim-polyglot'
Plug 'frazrepo/vim-rainbow'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'josa42/vim-lightline-coc'
Plug 'itchyny/lightline.vim'
call plug#end()

"https://linuxhandbook.com/vim-indentation-tab-spaces/
set autoindent
set noexpandtab
set tabstop=4 
set shiftwidth=4

"https://www.reddit.com/r/neovim/comments/131urrq/make_the_cursorline_in_neovim_semitransparent/
function! SearchFiles()
	:tabe
	:FZF
endfunction
nmap <C-g> :call SearchFiles() <CR>

"https://github.com/neoclide/coc.nvim/issues/3784
set t_Co=256
syntax enable
silent! colorscheme gruvbox
autocmd ColorScheme * highlight CocHighlightText gui=None guibg=#665c54
set background=dark
let g:coc_default_semantic_highlight_groups = 1

"https://jeffkreeftmeijer.com/vim-number/
set number
augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
	autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

"https://www.reddit.com/r/vim/comments/eck1tl/comment/fbcox26/
set cursorline

"https://github.com/neoclide/coc.nvim#example-vim-configuration
verbose imap <tab>
lua << EOF2
-- https://github.com/neoclide/coc.nvim#example-vim-configuration
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 1000 
vim.opt.signcolumn = "yes"
local keyset = vim.keymap.set
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end
local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)", {silent = true})
keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})
keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
keyset("n", "gr", "<Plug>(coc-references)", {silent = true})
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end
keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
    group = "CocGroup",
    command = "silent call CocActionAsync('highlight')",
    desc = "Highlight symbol under cursor on CursorHold"
})
vim.api.nvim_create_autocmd("FileType", {
    group = "CocGroup",
    pattern = "typescript,json",
    command = "setl formatexpr=CocAction('formatSelected')",
    desc = "Setup formatexpr specified filetype(s)."
})
vim.api.nvim_create_autocmd("User", {
    group = "CocGroup",
    pattern = "CocJumpPlaceholder",
    command = "call CocActionAsync('showSignatureHelp')",
    desc = "Update signature help on jump placeholder"
})
local opts = {silent = true, nowait = true, expr = true}
keyset("n", "<PageDown>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<PageDown>"', opts)
keyset("n", "<PageUp>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<PageUp>"', opts)
keyset("i", "<PageDown>",
       'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<PageUp>",
       'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<PageDown>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<PageDown>"', opts)
keyset("v", "<PageUp>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<PageUp>"', opts)
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})
vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})
vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")
local opts = {silent = true, nowait = true}
keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
keyset("n", "<space>j", ":<C-u>CocNext<cr>", opts)
keyset("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)
EOF2

let g:lightline = {
	\ 'active': {
  	\ 	'left': [['coc_info', 'coc_hints', 'coc_errors', 'coc_warnings', 'coc_ok'], ['coc_status']]
  	\ }
\ }

" register compoments:
call lightline#coc#register()


" copy paste
nnoremap <c-c> :call SetClipboardText()<CR>
nnoremap <c-v> :call GetClipboardText()<CR>
function! SetClipboardText()
	let l:yankedText = @"
	call system("((cat << \"EOF\" | termux-clipboard-set\n" . l:yankedText . "\nEOF\n);termux-toast \"Copied Yanked Text To Clipboard\") &> /dev/null &")
endfunction
function! GetClipboardText()
	let l:clipboardText = system("termux-clipboard-get; termux-toast \"Copied Clipboard Text To Yanked Register\"")
	let @" = l:clipboardText
endfunction


" fix wordwrap
set breakindent
set breakindentopt=shift:0
set showbreak====\ 
set wrap
set linebreak

" save vim or git keybind
nnoremap <c-s> :call Save()<CR>
function! Save()
	:wa
	echo system("(cd \"$(git rev-parse --show-toplevel)\"; bash git.bash push; termux-toast \"Git Pushed\")")
	:e!
endfunction
