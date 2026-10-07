local diff_tab -- tabpage of the open CodeDiff view, if any

-- Close the CodeDiff view if one is open, otherwise open it with `args`
local function toggle(args)
  if diff_tab and vim.api.nvim_tabpage_is_valid(diff_tab) then
    vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(diff_tab))
  else
    vim.cmd("CodeDiff " .. args)
  end
end

-- Branch the current one will merge into (origin/HEAD), falling back to main
local function base_branch()
  local res = vim.system({ "git", "rev-parse", "--abbrev-ref", "origin/HEAD" }, { text = true }):wait()
  return res.code == 0 and vim.trim(res.stdout) or "main"
end

return {
  {
    "esmuellert/codediff.nvim",
    lazy = true,
    cmd = "CodeDiff",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffOpen",
        callback = function(ev) diff_tab = ev.data.tabpage end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffClose",
        callback = function() diff_tab = nil end,
      })
    end,
    keys = {
      { "<leader>gd", function() toggle("") end, desc = "Toggle Diff (working changes)" },
      { "<leader>gD", function() toggle(base_branch() .. "...") end, desc = "Toggle Diff (branch vs base)" },
    },
    opts = {
      explorer = {
        line_stats = { enabled = true },
      },
      keymaps = {
        view = {
          next_hunk = { "]c", "]h" },
          prev_hunk = { "[c", "[h" },
        },
      },
    },
  },
}
