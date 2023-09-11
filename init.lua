-- Plugin Loading
-- TODO: Maybe migrate to packer
vim.cmd([[
    call plug#begin('~/.local/share/nvim/plugged')
        Plug 'vim-airline/vim-airline'
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
        Plug 'github/copilot.vim'
        Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

        Plug 'rust-lang/rust.vim'
        Plug 'Louis-Amas/noir-vim-support'
        Plug 'leafOfTree/vim-svelte-plugin'
    call plug#end()
]])

-- Key mapping
vim.g.mapleader = " "

vim.api.nvim_set_keymap('n', '<leader>s', ':split<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>S', ':vsplit<CR>', { noremap = true })
-- Switch to previous buffer
vim.api.nvim_set_keymap('n', '<leader><leader>', ':bp<CR>', { noremap = true })
-- Clear last search
vim.api.nvim_set_keymap('n', '<leader>c', ':let @/ = ""<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', ';', ':', { noremap = true })

vim.api.nvim_set_keymap('n', '<left>', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('n', '<right>', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('n', '<up>', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('n', '<down>', '<nop>', { noremap = true })

vim.api.nvim_set_keymap('v', '<left>', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('v', '<right>', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('v', '<up>', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('v', '<down>', '<nop>', { noremap = true })

-- Highlighting
vim.api.nvim_set_hl(0, 'SignColumn', { bg = "gray12" })
vim.api.nvim_set_hl(0, 'LineNr', { fg = "gray25" })

-- Highlight 100th column if we go over
vim.api.nvim_set_hl(0, 'ColorColumn',  { ctermbg = 0, bg = "magenta" })
vim.api.nvim_call_function('matchadd', {'ColorColumn', [[\%101v]], 100})

vim.o.backup = false
vim.o.colorscheme = "default"
vim.o.encoding = "utf-8"
vim.o.expandtab = true
vim.o.hidden = true -- Allows switching between multiple buffers (via :split and/or NERDTree)
vim.o.hlsearch = true
vim.o.lazyredraw = true
vim.o.mouse = "a"
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.spell = "yes"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.synmaxcol = 300
vim.o.syntax = true
vim.o.swapfile = false
vim.o.termguicolors = true
vim.o.updatetime = 300
vim.o.wrap = false
vim.o.writebackup = false

-- Tabs and Spaces --
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "rust", 
  callback = function()
    vim.api.nvim_buf_set_option(0, "tabstop", 4)
    vim.api.nvim_buf_set_option(0, "shiftwidth", 4)
    vim.api.nvim_buf_set_option(0, "softtabstop", 4)
  end
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "cpp",
  callback = function()
    vim.api.nvim_buf_set_option(0, "tabstop", 4)
    vim.api.nvim_buf_set_option(0, "shiftwidth", 4)
    vim.api.nvim_buf_set_option(0, "softtabstop", 4)
  end
})

-- Code Folding
vim.o.foldmethod = "syntax"
vim.o.foldlevel = 99

vim.o.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  extends = "›",
  precedes = "‹",
  nbsp = "␣",
}

-- CoC Stuff
vim.cmd([[
    inoremap <silent><expr> <TAB>
          \ coc#pum#visible() ? coc#pum#next(1) :
          \ CheckBackspace() ? "\<Tab>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

    function! CheckBackspace() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction
]])
