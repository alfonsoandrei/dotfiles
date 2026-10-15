return {
  {
    "jellydn/hurl.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = "hurl",
    -- Runs read the file on disk, so normal-mode run maps save first.
    keys = {
      { "<leader>rr", "<cmd>update<cr><cmd>HurlRunnerAt<cr>", ft = "hurl", desc = "Run Request Under Cursor" },
      { "<leader>rR", "<cmd>update<cr><cmd>HurlRunner<cr>", ft = "hurl", desc = "Run All Requests" },
      { "<leader>re", "<cmd>update<cr><cmd>HurlRunnerToEntry<cr>", ft = "hurl", desc = "Run Requests Up To Cursor" },
      { "<leader>rE", "<cmd>update<cr><cmd>HurlRunnerToEnd<cr>", ft = "hurl", desc = "Run Requests From Cursor To End" },
      { "<leader>rv", "<cmd>update<cr><cmd>HurlVerbose<cr>", ft = "hurl", desc = "Run Request (Verbose)" },
      { "<leader>rV", "<cmd>update<cr><cmd>HurlVeryVerbose<cr>", ft = "hurl", desc = "Run Request (Very Verbose)" },
      { "<leader>rl", "<cmd>HurlShowLastResponse<cr>", ft = "hurl", desc = "Show Last Response" },
      { "<leader>rm", "<cmd>HurlToggleMode<cr>", ft = "hurl", desc = "Toggle Response Split/Popup" },
      { "<leader>rs", "<cmd>HurlSelectEnvFile<cr>", ft = "hurl", desc = "Select Env File" },
      { "<leader>rr", ":HurlRunner<cr>", ft = "hurl", mode = "v", desc = "Run Selected Requests" },
    },
    opts = {
      mode = "split",
      -- Needs jq (Brewfile). Display formatting only; Hurl asserts use JSONPath.
      formatters = {
        json = { "jq" },
      },
      -- Keep secrets in a git-ignored env file (see config/.config/git/ignore).
      env_file = { "vars.env" },
    },
  },
}
