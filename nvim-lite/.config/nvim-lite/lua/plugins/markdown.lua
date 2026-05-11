return {
  {
    "OXY2DEV/markview.nvim",
    lazy = true,
    ft = { "markdown" },
    config = function()
      vim.g.markview_conceal_same_line = 1
      require("markview").setup({
        preview = {
          modes = { "n", "i", "no", "c" },
          hybrid_modes = { "i" },
          callbacks = {
            on_enable = function(_, win)
              vim.wo[win].conceallevel = 2
              vim.wo[win].concealcursor = "c"
            end
          },
        },

        markdown = {
          block_quotes = { enable = true },
          code_blocks = { enable = true, style = "language" },
          headings = { enable = true, shift_width = 0 },
          list_items = { enable = true },
        },
        markdown_inline = {
          checkboxes = { enable = true },
          inline_codes = { enable = true },
        },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.icons",
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    ft = { "markdown" },
    -- If :MarkdownPreview does nothing, run: cd ~/.local/share/nvim-lite/lazy/markdown-preview.nvim/app && yarn
    build = "cd app && yarn",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Toggle markdown preview" },
    },
  },

  {
    "3rd/image.nvim",
    event = "VeryLazy",
    config = function()
      vim.g.image_display_enabled = true
      require("image").setup({
        backend = "kitty",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = true,
            download_remote_images = true,
            only_render_image_at_cursor = true,
            filetypes = { "markdown", "vimwiki" },
          },
          neorg = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = true,
            filetypes = { "norg" },
          },
        },
        max_width = 140,
        max_height = 20,
        window_overlap_clear_enabled = false,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = false,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg" },
      })
    end,
  },
}
