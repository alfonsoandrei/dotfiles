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
    picker = { enabled = true },
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
