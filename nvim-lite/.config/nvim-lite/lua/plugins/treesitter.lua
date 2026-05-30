return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      require("nvim-treesitter").update()
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
    config = function()
      require("nvim-treesitter").install({
        "bash", "c", "cpp", "css", "go", "gomod", "gowork", "gosum",
        "html", "javascript", "json", "lua", "luadoc",
        "markdown", "markdown_inline", "python", "regex", "rust",
        "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
      })
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
          pcall(vim.treesitter.start, buf)
        end
      end
    end,
  },
}
