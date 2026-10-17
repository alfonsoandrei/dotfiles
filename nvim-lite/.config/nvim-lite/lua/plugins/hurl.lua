-- Secrets come from pass (<HURL_PASS_PREFIX>/<env>/<name>) and are exported as
-- HURL_SECRET_<name> before each run.
local loaded = { env = nil, names = {} }

local function active_env()
  local file = _HURL_GLOBAL_CONFIG.env_file[1]
  if not vim.startswith(file, "/") then
    file = vim.fs.find(file, { upward = true, path = vim.fn.expand("%:p:h") })[1]
  end
  return file and vim.fn.fnamemodify(vim.fn.resolve(file), ":t:r")
end

local function load_secrets()
  local prefix = vim.env.HURL_PASS_PREFIX
  local env = active_env()
  if not prefix or not env or env == loaded.env then
    return
  end
  for _, name in ipairs(loaded.names) do
    vim.env["HURL_SECRET_" .. name] = nil
  end
  loaded = { env = env, names = {} }
  local dir = (vim.env.PASSWORD_STORE_DIR or vim.fn.expand("~/.password-store")) .. "/" .. prefix .. "/" .. env
  for _, path in ipairs(vim.fn.glob(dir .. "/*.gpg", false, true)) do
    local name = vim.fn.fnamemodify(path, ":t:r")
    local out = vim.system({ "pass", "show", prefix .. "/" .. env .. "/" .. name }, { text = true }):wait()
    if out.code ~= 0 then
      loaded.env = nil
      vim.notify("hurl: pass could not decrypt " .. prefix .. "/" .. env .. "/" .. name, vim.log.levels.WARN)
      return
    end
    vim.env["HURL_SECRET_" .. name] = vim.split(out.stdout, "\n")[1]
    table.insert(loaded.names, name)
  end
end

-- Runs read the file on disk, so normal-mode run maps save first.
local function run(cmd, visual)
  return function()
    if visual then
      vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    else
      vim.cmd("update")
    end
    load_secrets()
    vim.cmd(cmd)
  end
end

return {
  {
    "jellydn/hurl.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = "hurl",
    keys = {
      { "<leader>rr", run("HurlRunnerAt"), ft = "hurl", desc = "Run Request Under Cursor" },
      { "<leader>rR", run("HurlRunner"), ft = "hurl", desc = "Run All Requests" },
      { "<leader>re", run("HurlRunnerToEntry"), ft = "hurl", desc = "Run Requests Up To Cursor" },
      { "<leader>rE", run("HurlRunnerToEnd"), ft = "hurl", desc = "Run Requests From Cursor To End" },
      { "<leader>rv", run("HurlVerbose"), ft = "hurl", desc = "Run Request (Verbose)" },
      { "<leader>rV", run("HurlVeryVerbose"), ft = "hurl", desc = "Run Request (Very Verbose)" },
      { "<leader>rl", "<cmd>HurlShowLastResponse<cr>", ft = "hurl", desc = "Show Last Response" },
      { "<leader>rm", "<cmd>HurlToggleMode<cr>", ft = "hurl", desc = "Toggle Response Split/Popup" },
      { "<leader>rs", "<cmd>HurlSelectEnvFile<cr>", ft = "hurl", desc = "Select Env File" },
      { "<leader>rr", run("'<,'>HurlRunner", true), ft = "hurl", mode = "v", desc = "Run Selected Requests" },
    },
    opts = {
      mode = "split",
      -- Needs jq (Brewfile). Display formatting only; Hurl asserts use JSONPath.
      formatters = {
        json = { "jq" },
      },
      -- Git-ignored; secrets come from pass (see load_secrets).
      env_file = { "vars.env" },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 1, {
        function() return "hurl: " .. (active_env() or "none") end,
        cond = function() return vim.bo.filetype == "hurl" and _HURL_GLOBAL_CONFIG ~= nil end,
      })
    end,
  },
}
