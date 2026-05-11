local map = vim.keymap.set

-- General
map("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Exit insert mode" })

-- LSP navigation (uses Snacks.picker when available, falls back to vim.lsp.buf)
map("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
map("n", "gr", function() Snacks.picker.lsp_references() end, { nowait = true, desc = "References" })
map("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto Type Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })

map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Files
map("n", "<leader>cR", function() Snacks.rename.rename_file() end, { desc = "Rename File" })

-- Spell checking
map("n", "<leader>sg", "zg", { noremap = true, silent = true, desc = "Add word to dictionary" })
map("n", "<leader>sw", "zw", { noremap = true, silent = true, desc = "Mark word as misspelled" })
map("n", "<leader>ts", function()
  vim.wo.spell = not vim.wo.spell
  vim.notify(vim.wo.spell and "Spell checking enabled" or "Spell checking disabled", vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Toggle spell checking" })

-- Surround (Visual)
map("v", "S", function()
  local char = vim.fn.getcharstr()
  local pairs = {
    ["("] = { "(", ")" },
    [")"] = { "(", ")" },
    ["b"] = { "(", ")" },
    ["["] = { "[", "]" },
    ["]"] = { "[", "]" },
    ["{"] = { "{", "}" },
    ["}"] = { "{", "}" },
    ["B"] = { "{", "}" },
    ["<"] = { "<", ">" },
    [">"] = { "<", ">" },
  }
  local left, right
  if pairs[char] then
    left, right = pairs[char][1], pairs[char][2]
  else
    left, right = char, char
  end
  vim.cmd("normal! c" .. left .. "\027pa" .. right .. "\027")
end, { noremap = true, desc = "Surround selection" })

-- vim-tmux-navigator (handles C-h/j/k/l for both nvim windows and tmux panes)

-- Better buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Last Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear highlights" })
