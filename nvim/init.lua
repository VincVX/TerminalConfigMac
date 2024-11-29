-- Automatically install packer.nvim if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      'git',
      'clone',
      '--depth',
      '1',
      'https://github.com/wbthomason/packer.nvim',
      install_path,
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

ensure_packer()

-- Use a protected call to avoid errors on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
  vim.notify('Packer.nvim is not installed')
  return
end

-- Packer plugin specifications
packer.startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Syntax highlighting for multiple languages using Tree-sitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }

  -- Tokyo Night theme plugin
  use 'folke/tokyonight.nvim'

  -- Neovim Code Runner plugin
  use { 'CRAG666/code_runner.nvim', branch = 'main' }

  -- Autocompletion plugins
  use 'hrsh7th/nvim-cmp'          -- Completion engine
  use 'hrsh7th/cmp-nvim-lsp'      -- LSP completion source
  use 'hrsh7th/cmp-buffer'        -- Buffer completions
  use 'hrsh7th/cmp-path'          -- Path completions
  use 'hrsh7th/cmp-cmdline'       -- Command-line completions

  -- Snippet engine and snippet completions
  use 'L3MON4D3/LuaSnip'          -- Snippet engine
  use 'saadparwaiz1/cmp_luasnip'  -- Snippet completions

  -- LSP configurations
  use 'neovim/nvim-lspconfig'     -- LSP configurations

  -- Auto-pairs plugin for automatic bracket insertion
  use 'jiangmiao/auto-pairs'

  -- File browser plugin
  use {
    'nvim-tree/nvim-tree.lua',
    requires = { 'nvim-tree/nvim-web-devicons' }, -- Optional, for file icons
  }

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Set Tokyo Night theme style to 'night'
vim.g.tokyonight_style = 'night'
vim.cmd('colorscheme tokyonight')

-- Configure Tree-sitter for syntax highlighting
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'typescript', 'lua', 'python', 'go', 'swift' },  -- Languages to install
  sync_install = false,
  highlight = {
    enable = true,                -- Enable Tree-sitter
    additional_vim_regex_highlighting = false,  -- Disable Vim's regex highlighting
  },
})

-- Set up Code Runner for different languages
require('code_runner').setup({
  filetype = {
    python = 'python3 -u',
    javascript = 'node',
    typescript = 'ts-node',
    lua = 'lua',
    go = 'go run',
    swift = 'swift',
  },
})

-- Set up nvim-cmp for autocompletion
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- Use LuaSnip for snippet expansion
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept completion
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },  -- LSP source
    { name = 'luasnip' },   -- Snippet source
    { name = 'buffer' },    -- Buffer source
    { name = 'path' },      -- Path source
  }),
})

-- Set up language server configurations
local lspconfig = require('lspconfig')

-- TypeScript/JavaScript (replace tsserver with ts_ls)
lspconfig.ts_ls.setup({})

-- TypeScript/JavaScript
--lspconfig.tsserver.setup({})

-- Python
lspconfig.pyright.setup({})

-- Go
lspconfig.gopls.setup({})

-- Lua
lspconfig.lua_ls.setup({})

-- Key mappings for Code Runner using F9
vim.api.nvim_set_keymap('n', '<F9>', ':RunCode<CR>', { noremap = true, silent = true })

-- More comfortable bracket bindings for German keyboard layout
vim.api.nvim_set_keymap('i', '<A-9>', '[]<Left>', { noremap = true, silent = true }) -- Alt+9 for []
vim.api.nvim_set_keymap('i', '<A-8>', '{}<Left>', { noremap = true, silent = true }) -- Alt+8 for {}
vim.api.nvim_set_keymap('i', '<A-7>', '()<Left>', { noremap = true, silent = true }) -- Alt+7 for ()
vim.api.nvim_set_keymap('i', '<A-0>', '<>', { noremap = true, silent = true }) -- Alt+0 for <>

-- Navigation between brackets
vim.api.nvim_set_keymap('n', '<A-[>', '%', { noremap = true, silent = true }) -- Jump to matching bracket

-- Set up nvim-tree
require('nvim-tree').setup({
  disable_netrw = true,  -- Disable netrw (default file explorer)
  hijack_netrw = true,   -- Use nvim-tree instead of netrw
  renderer = {
    icons = {
      glyphs = {
        default = "",  -- Default file icon
        symlink = "",  -- Symlink icon
      },
    },
  },
  view = {
    width = 30,        -- Width of the file explorer
    side = 'left',     -- Open on the left side of the screen
  },
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- Key mappings
    vim.keymap.set('n', 'o', api.node.open.edit, opts('Open File or Folder'))
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open File or Folder'))
    vim.keymap.set('n', 't', api.node.open.tab, opts('Open File in New Tab'))
    vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open File in Horizontal Split'))
    vim.keymap.set('n', 'i', api.node.open.vertical, opts('Open File in Vertical Split'))
    vim.keymap.set('n', 'x', api.node.navigate.parent_close, opts('Close Parent Folder'))
    vim.keymap.set('n', 'u', api.tree.change_root_to_parent, opts('Go up a directory')) -- Already included
    vim.keymap.set('n', 'r', api.tree.reload, opts('Reload Tree'))
    vim.keymap.set('n', 'q', api.tree.close, opts('Close Tree'))
  end,
})
