-- ==== init.lua (Neovim >= 0.9) ==============================================

vim.g.loaded_node_provider   = 0
vim.g.loaded_ruby_provider   = 0
vim.g.loaded_perl_provider   = 0
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")

-- Leader keys first
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Speed up module loading on 0.9+
pcall(function() vim.loader.enable() end)

-- Netrw off for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bootstrap lazy.nvim ---------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git","--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Theme
  { "folke/tokyonight.nvim", lazy = false, priority = 1000,
    opts = { style = "moon", terminal_colors = true },
    config = function() vim.cmd.colorscheme("tokyonight") end
  },

  { "echasnovski/mini.icons", version = false },

  { "github/copilot.vim" },

  -- UI / UX
  { "nvim-lualine/lualine.nvim" },
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "folke/which-key.nvim", opts = {} },

  -- Files / search
  { "nvim-tree/nvim-tree.lua", opts = {} },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Syntax / TS
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP + completion
  { "neovim/nvim-lspconfig" },
  { "mrcjkb/rustaceanvim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- QoL
  { "numToStr/Comment.nvim", opts = {} },
  { "kylechui/nvim-surround", opts = {} },
})

-- Options ---------------------------------------------------------------------
local opt = vim.opt
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.splitbelow = true
opt.splitright = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 300
opt.timeoutlen = 400
opt.wrap = false
opt.scrolloff = 4
opt.sidescrolloff = 8

-- Columns / whitespace
opt.colorcolumn = "101"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", extends = "›", precedes = "‹", nbsp = "␣" }

-- Indentation defaults (override per ft below)
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- Folding via Treesitter
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99

opt.cursorline = true

-- Autocmds --------------------------------------------------------------------
-- Spell/wrap for prose
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.colorcolumn = ""
  end,
})

-- 4-space indents for systems languages
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "rust", "cpp", "c" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Keymaps ---------------------------------------------------------------------
local map, kmopts = vim.keymap.set, { silent = true, noremap = true }
map("n", ";", ":", kmopts)
map("n", "<leader>s", "<cmd>split<CR>", kmopts)
map("n", "<leader>S", "<cmd>vsplit<CR>", kmopts)
map("n", "<leader><leader>", "<cmd>b#<CR>", kmopts)
map("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", kmopts)
map({ "n", "v" }, "<left>", "<nop>", kmopts)
map({ "n", "v" }, "<right>", "<nop>", kmopts)
map({ "n", "v" }, "<up>", "<nop>", kmopts)
map({ "n", "v" }, "<down>", "<nop>", kmopts)

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", kmopts)
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", kmopts)
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", kmopts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", kmopts)
map("n", "<leader>e",  "<cmd>NvimTreeToggle<CR>", kmopts)

-- Treesitter ------------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "rust","lua","vim","vimdoc","bash","toml","json","yaml",
    "markdown","markdown_inline","regex"
  },
  highlight = { enable = true },
  indent    = { enable = true },
})

-- Mini-Icons -------
require("mini.icons").setup()
pcall(function() require("mini.icons").mock_nvim_web_devicons() end)

-- Statusline ------------------------------------------------------------------
require("lualine").setup({ options = { theme = "auto" } })

-- Completion ------------------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"]   = cmp.mapping.confirm({ select = true }),
    ["<Tab>"]  = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback() end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback() end
    end, { "i", "s" }),
  }),
  sources = {
    { name = "nvim_lsp" }, { name = "path" }, { name = "buffer" }, { name = "luasnip" }
  }
})

-- Telescope ------
require("telescope").load_extension("fzf")

-- LSP base --------------------------------------------------------------------
local function on_attach(_, bufnr)
  local b = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = bufnr })
  end
  b("n", "gd", vim.lsp.buf.definition)
  b("n", "gD", vim.lsp.buf.declaration)
  b("n", "gi", vim.lsp.buf.implementation)
  b("n", "gr", require("telescope.builtin").lsp_references)
  b("n", "K",  vim.lsp.buf.hover)
  b("n", "<leader>rn", vim.lsp.buf.rename)
  b("n", "<leader>ca", vim.lsp.buf.code_action)
  b("n", "[d", vim.diagnostic.goto_prev)
  b("n", "]d", vim.diagnostic.goto_next)
  b("n", "gl", vim.diagnostic.open_float)
  b("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()


-- rustaceanvim: config via global
vim.g.rustaceanvim = {
  server = {
    on_attach = function(client, bufnr)
      -- Set up LSP-related key mappings
      if package.loaded.telescope then
        vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, { buffer = bufnr, silent = true })
      end
      vim.keymap.set("n", "gd", vim.lsp.buf.definition,   { buffer = bufnr, silent = true })
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration,  { buffer = bufnr, silent = true })
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation,{ buffer = bufnr, silent = true })
      vim.keymap.set("n", "K",  vim.lsp.buf.hover,        { buffer = bufnr, silent = true })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,{ buffer = bufnr, silent = true })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,{ buffer = bufnr, silent = true })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, silent = true })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, silent = true })
      vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { buffer = bufnr, silent = true })

      -- Inlay hints (handle API changes across 0.10/0.11)
      local ih = vim.lsp.inlay_hint
      if type(ih) == "table" and ih.enable then
        ih.enable(true, { bufnr = bufnr })
      elseif type(ih) == "function" then
        ih(bufnr, true)
      end
    end,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = { command = "clippy" },
      },
    },
  },
}

-- Lua LSP for editing your config --------------------------------------------
require("lspconfig").lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      diagnostics = { globals = { "vim" } },
    }
  }
})

-- Diagnostics UI --------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
-- ============================================================================


-- OSC52 clipboard fallback ----
if os.getenv("SSH_TTY") or os.getenv("TMUX") then
  vim.g.clipboard = require("vim.ui.clipboard.osc52")
end

-- stop comment continuation
vim.opt.formatoptions:remove({ "c", "r", "o" })

-- format Rust on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function() vim.lsp.buf.format({ async = false }) end,
})

