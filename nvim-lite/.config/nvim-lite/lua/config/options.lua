local opt = vim.opt

vim.g.mapleader = " "

-- Remap .mjs filetype so ts_ls doesn't attach and crash trying to load tsconfig.json.
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
opt.cmdheight = 0

-- Default tab labels use a shortened path. Show the active window's file name.
function _G.nvim_lite_tabline()
  local parts = {}
  local current = vim.fn.tabpagenr()
  for i = 1, vim.fn.tabpagenr("$") do
    local bufnr = vim.fn.tabpagebuflist(i)[vim.fn.tabpagewinnr(i)]
    local name = vim.api.nvim_buf_get_name(bufnr)
    local label = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
    label = label:gsub("%%", "%%%%")
    if vim.bo[bufnr].modified then
      label = label .. " +"
    end
    local hl = i == current and "%#TabLineSel#" or "%#TabLine#"
    parts[#parts + 1] = hl .. "%" .. i .. "T " .. i .. " " .. label .. " "
  end
  return table.concat(parts) .. "%#TabLineFill#%T"
end

opt.tabline = "%!v:lua.nvim_lite_tabline()"

-- Command-line completion
opt.wildoptions = "pum,fuzzy"
opt.wildmode = "noselect:lastused,full"

-- Clipboard
-- yank into system clip board directly
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
