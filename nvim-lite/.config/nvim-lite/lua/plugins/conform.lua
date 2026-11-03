local eslint_fts = { "typescript", "typescriptreact", "javascript", "javascriptreact" }

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = { "ConformInfo" },
  init = function()
    -- Type-aware ESLint (parserOptions.project) spends ~12s building the TS program
    -- on a cold daemon, well past the format-on-save timeout. Keep the daemon alive
    -- for a workday instead of the 15 min default, and warm it when a file is opened
    -- so the first save hits a ready daemon.
    vim.env.ESLINT_D_IDLE = vim.env.ESLINT_D_IDLE or "480"

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("eslint_d_prewarm", { clear = true }),
      pattern = eslint_fts,
      callback = function(args)
        local file = vim.api.nvim_buf_get_name(args.buf)
        if file == "" or vim.fn.executable("eslint_d") == 0 then
          return
        end
        local root = vim.fs.root(file, { "eslint.config.mjs", "eslint.config.js", "eslint.config.cjs", "package.json" })
        if not root then
          return
        end
        vim.system({ "eslint_d", file }, { cwd = root, text = true }, function() end)
      end,
    })
  end,
  opts = {
    formatters_by_ft = {
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      go = { "goimports", "gofmt" },
      python = { "ruff_format" },
      cpp = { "clang_format" },
      c = { "clang_format" },
      lua = { "stylua" },
    },
    format_on_save = {
      timeout_ms = 3000,
      lsp_format = "fallback",
    },
  },
}
