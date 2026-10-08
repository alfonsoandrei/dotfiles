return {
  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>th", function()
        local hardtime = require("hardtime")
        hardtime.toggle()
        vim.notify(hardtime.is_plugin_enabled and "Hardtime enabled" or "Hardtime disabled", vim.log.levels.INFO)
      end, desc = "Toggle Hardtime" },
      { "<leader>tH", "<cmd>Hardtime report<cr>", desc = "Hardtime Report" },
    },
    opts = {
      disable_mouse = false,
      -- List UIs where repeated j/k is how you move
      disabled_filetypes = {
        ["codediff.*"] = true,
        ["snacks_.*"] = true,
      },
    },
  },
}
