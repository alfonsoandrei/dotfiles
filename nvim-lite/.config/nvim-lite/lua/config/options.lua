local opt = vim.opt

vim.g.mapleader = " "

-- Remap .mjs filetype so vtsls doesn't attach and crash trying to load tsconfig.json.
vim.filetype.add({ extension = { mjs = "mjs" } })
vim.treesitter.language.register("javascript", "mjs")

-- UI
opt.guicursor = "n:block-blinkon250-blinkoff150,i:ver25"
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.scrolloff = 4
opt.cursorline = true
opt.showmode = false

-- Clipboard
-- yank into system clip board directly
-- tmux cross panel copy
opt.clipboard = "unnamedplus"

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.splitbelow = true
opt.splitright = true

-- Session options for auto-session
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Conceal settings for markdown
opt.conceallevel = 2
opt.concealcursor = ""

-- Spell checking
opt.spelllang = "en_us"
opt.spellsuggest = "best,9"
opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

-- Diagnostics
vim.diagnostic.config({
  virtual_text = false,
  float = {
    source = true,
    border = "rounded",
    width = 80,
  },
})
