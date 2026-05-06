local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Markdown settings
autocmd("FileType", {
  group = augroup("markdown-settings", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = ""
    vim.opt_local.suffixesadd:append(".md")

    -- Follow markdown links: [text](path) and [[path]]
    vim.keymap.set("n", "gf", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1

      for link_start, path, link_end in line:gmatch("()%[.-%]%((.-)%)()") do
        if col >= link_start and col < link_end then
          path = path:gsub("#.*$", "")
          if path ~= "" then
            vim.cmd("edit " .. vim.fn.fnameescape(path))
            return
          end
        end
      end

      for link_start, path, link_end in line:gmatch("()%[%[(.-)%]%]()") do
        if col >= link_start and col < link_end then
          path = path:gsub("|.*$", "")
          if not path:match("%.%w+$") then
            path = path .. ".md"
          end
          vim.cmd("edit " .. vim.fn.fnameescape(path))
          return
        end
      end

      vim.cmd("normal! gF")
    end, { buffer = true, noremap = true, silent = true, desc = "Follow markdown link" })
  end,
})

-- Resize splits on window resize
autocmd("VimResized", {
  group = augroup("resize-splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Go to last location when opening a buffer
autocmd("BufReadPost", {
  group = augroup("last-location", { clear = true }),
  callback = function(event)
    local buf = event.buf
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
