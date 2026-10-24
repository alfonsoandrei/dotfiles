-- Bitbucket line anchors are #lines-12 or #lines-12:20
local function bitbucket_lines(f)
  if f.line_start == f.line_end then
    return ("#lines-%d"):format(f.line_start)
  end
  return ("#lines-%d:%d"):format(f.line_start, f.line_end)
end

-- Bitbucket can't resolve branch names with "/" in /src/<branch>/ paths, so link
-- the pushed commit (like Bitbucket's own UI) and keep the branch in ?at=
local function bitbucket_file(f)
  local dir = vim.fn.expand("%:p:h")
  local res = vim.system({ "git", "-C", dir, "rev-parse", "@{upstream}" }, { text = true }):wait()
  if res.code ~= 0 then
    res = vim.system({ "git", "-C", dir, "rev-parse", "HEAD" }, { text = true }):wait()
  end
  local at = (f.branch:gsub("/", "%%2F"))
  return ("/src/%s/%s?at=%s%s"):format(vim.trim(res.stdout), f.file, at, bitbucket_lines(f))
end

-- Snacks pickers are floating windows, and vim-tmux-navigator never sees a float at the
-- edge, so <C-h/j/k/l> got stuck in nvim. The explorer sits on a real sidebar window
-- (the layout root): look for a neighbour from there and fall back to tmux at the edge.
-- Floating pickers close and navigate from the window they were opened from.
-- Leave insert mode first and move on the next tick, or keystrokes leak into the target buffer.
local function tmux_navigate(key, pane, command)
  return function(picker)
    vim.cmd.stopinsert()
    local root = picker.layout.root and picker.layout.root.win
    if root and vim.api.nvim_win_is_valid(root) and vim.api.nvim_win_get_config(root).relative == "" then
      local target = vim.api.nvim_win_call(root, function() return vim.fn.win_getid(vim.fn.winnr(key)) end)
      vim.schedule(function()
        if target ~= root then
          vim.api.nvim_set_current_win(target)
        elseif vim.env.TMUX then
          vim.system({ "tmux", "select-pane", "-" .. pane })
        end
      end)
    else
      picker:close()
      vim.schedule(function() vim.cmd("TmuxNavigate" .. command) end)
    end
  end
end

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    dashboard = {
      enabled = false,
    },
    gitbrowse = {
      url_patterns = {
        ["bitbucket%.org"] = {
          branch = "/branch/{branch}",
          file = bitbucket_file,
          permalink = function(f) return "/src/" .. f.commit .. "/" .. f.file .. bitbucket_lines(f) end,
        },
      },
    },
    picker = {
      enabled = true,
      actions = {
        tmux_left = tmux_navigate("h", "L", "Left"),
        tmux_down = tmux_navigate("j", "D", "Down"),
        tmux_up = tmux_navigate("k", "U", "Up"),
        tmux_right = tmux_navigate("l", "R", "Right"),
      },
      -- Pickers keep <C-j>/<C-k> for moving through results.
      win = {
        input = {
          keys = {
            ["<c-h>"] = { "tmux_left", mode = { "i", "n" } },
            ["<c-l>"] = { "tmux_right", mode = { "i", "n" } },
          },
        },
        list = {
          keys = {
            ["<c-h>"] = "tmux_left",
            ["<c-l>"] = "tmux_right",
          },
        },
      },
      -- The explorer list is in normal mode where j/k already move, so all four go to tmux.
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["<c-h>"] = "tmux_left",
                ["<c-j>"] = "tmux_down",
                ["<c-k>"] = "tmux_up",
                ["<c-l>"] = "tmux_right",
              },
            },
          },
        },
      },
    },
    notifier = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- Find
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fF", function() Snacks.picker.files({ ignored = true, hidden = true }) end, desc = "Find Ignored/Hidden Files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>fG", function() Snacks.picker.grep({ ignored = true, hidden = true }) end, desc = "Grep (including Ignored/Hidden)" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Grep Word", mode = { "n", "x" } },
    -- Git
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>go", function() Snacks.gitbrowse() end, desc = "Git Browse (open)", mode = { "n", "x" } },
    { "<leader>gy", function()
      Snacks.gitbrowse({
        notify = false,
        open = function(url)
          vim.fn.setreg("+", url)
          vim.notify("Copied " .. url, vim.log.levels.INFO)
        end,
      })
    end, desc = "Git Browse (copy url)", mode = { "n", "x" } },
    -- Search
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    -- Explorer
    { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
    -- Notifications
    { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
  },
}
