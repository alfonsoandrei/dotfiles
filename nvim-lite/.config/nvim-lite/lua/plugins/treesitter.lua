return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "bash", "c", "cpp", "css", "go", "gomod", "gowork", "gosum",
        "html", "javascript", "json", "jsonc", "lua", "luadoc",
        "markdown", "markdown_inline", "python", "regex", "rust",
        "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
