return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "bash", "c", "cpp", "css", "go", "gomod", "gowork", "gosum",
          "html", "javascript", "json", "jsonc", "lua", "luadoc",
          "markdown", "markdown_inline", "python", "regex", "rust",
          "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
        },
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
