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

-- Fetch, pick a remote branch and review it against the base, like a Bitbucket PR
local function review_branch()
  if diff_tab and vim.api.nvim_tabpage_is_valid(diff_tab) then
    return toggle("")
  end
  vim.notify("Fetching origin...", vim.log.levels.INFO)
  vim.system({ "git", "fetch", "--prune", "origin" }, { text = true }, vim.schedule_wrap(function(fetch)
    if fetch.code ~= 0 then
      return vim.notify("git fetch failed:\n" .. fetch.stderr, vim.log.levels.ERROR)
    end
    local base = base_branch()
    local refs = vim.system(
      { "git", "for-each-ref", "--sort=-committerdate", "--format=%(refname:short)", "refs/remotes/origin" },
      { text = true }
    ):wait()
    -- origin/HEAD shortens to "origin"
    local branches = vim.tbl_filter(function(b)
      return b ~= base and b ~= "origin" and b ~= "origin/HEAD"
    end, vim.split(refs.stdout, "\n", { trimempty = true }))
    vim.ui.select(branches, { prompt = "Review branch against " .. base }, function(branch)
      if branch then
        vim.cmd("CodeDiff " .. base .. "..." .. branch)
      end
    end)
  end))
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
      { "<leader>gB", review_branch, desc = "Toggle Diff (review remote branch)" },
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
