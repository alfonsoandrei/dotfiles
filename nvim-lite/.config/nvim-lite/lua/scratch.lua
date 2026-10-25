-- Scratchpad notes in ~/Documents/git/scratch, opened by ~/.scripts/scratch in a floating Ghostty window.
-- History is a list of notes, most recently opened first. "last" reopens its top entry.
local M = {}

local dir = vim.fn.expand("~/Documents/git/scratch")
local history_file = vim.fn.stdpath("state") .. "/scratch-history"
local history_size = 50

local function is_note(path)
  return vim.startswith(path, dir .. "/") and path:match("%.md$") ~= nil
end

-- Entries whose file was renamed or deleted drop out here.
local function read_history()
  local ok, lines = pcall(vim.fn.readfile, history_file)
  if not ok then return {} end
  return vim.tbl_filter(function(path) return vim.uv.fs_stat(path) ~= nil end, lines)
end

local function record(path)
  local entries = { path }
  for _, entry in ipairs(read_history()) do
    if entry ~= path and #entries < history_size then table.insert(entries, entry) end
  end
  local tmp = history_file .. ".tmp"
  vim.fn.writefile(entries, tmp)
  vim.uv.fs_rename(tmp, history_file)
end

function M.new()
  vim.cmd.edit(vim.fn.fnameescape(dir .. "/" .. os.date("%Y-%m-%d-%H%M%S") .. ".md"))
end

-- Re-editing the current note would fail on unsaved changes, and there is nothing to open anyway.
function M.open(path)
  if vim.api.nvim_buf_get_name(0) == path then return end
  vim.cmd.edit(vim.fn.fnameescape(path))
end

function M.last()
  local last = read_history()[1]
  if last then M.open(last) else M.new() end
end

-- History first, then notes never opened through here, newest first.
function M.history()
  local seen, items = {}, {}
  local function add(path)
    if seen[path] then return end
    seen[path] = true
    table.insert(items, { file = path, text = vim.fn.fnamemodify(path, ":t") })
  end
  for _, path in ipairs(read_history()) do add(path) end
  local rest = vim.fn.glob(dir .. "/*.md", false, true)
  table.sort(rest, function(a, b) return vim.fn.getftime(a) > vim.fn.getftime(b) end)
  for _, path in ipairs(rest) do add(path) end

  Snacks.picker.pick({
    title = "Scratch",
    items = items,
    format = "file",
    preview = "file",
    -- Snacks closes an empty picker on its own, which would leave a bare nvim.
    show_empty = true,
  })
end

-- Entry point for the scratch window, run as nvim -c "lua require('scratch').start()".
function M.start()
  vim.fn.mkdir(dir, "p")
  vim.cmd.cd(vim.fn.fnameescape(dir))

  -- Closing the window kills nvim without asking, so save notes as you go and keep no swap files.
  vim.o.swapfile = false
  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
    group = vim.api.nvim_create_augroup("scratch-autosave", { clear = true }),
    callback = function(args)
      if vim.bo[args.buf].modified and is_note(vim.api.nvim_buf_get_name(args.buf)) then
        vim.api.nvim_buf_call(args.buf, function() vim.cmd("silent update") end)
      end
    end,
  })

  -- Only real note windows count, not picker previews. A new note counts once it is saved.
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("scratch-history", { clear = true }),
    callback = function(args)
      local path = vim.api.nvim_buf_get_name(args.buf)
      if vim.bo[args.buf].buftype == "" and vim.api.nvim_win_get_config(0).relative == ""
          and is_note(path) and vim.uv.fs_stat(path) then
        record(path)
      end
    end,
  })

  local map = vim.keymap.set
  map("n", "<leader>xn", M.new, { desc = "Scratch: New Note" })
  map("n", "<leader>xl", M.last, { desc = "Scratch: Last Note" })
  map("n", "<leader>xh", M.history, { desc = "Scratch: History" })

  M.run(vim.env.SCRATCH_ACTION, vim.env.SCRATCH_FILE)
end

-- Float and center the window once AeroSpace has placed it, and after ~/.scripts/scratch moved it
-- to the current workspace.
local function place()
  vim.defer_fn(function() vim.system({ vim.fn.expand("~/.scripts/scratch"), "place" }) end, 300)
end

-- Called at startup and by ~/.scripts/scratch through the --listen socket when the window is already open.
-- Leave insert mode first, and run on the next tick so the RPC call returns straight away.
function M.run(action, file)
  place()
  vim.schedule(function()
    vim.cmd.stopinsert()
    if action == "open" and file and file ~= "" then
      M.open(file)
    elseif action == "new" or action == "history" then
      M[action]()
    else
      M.last()
    end
  end)
  return ""
end

return M
