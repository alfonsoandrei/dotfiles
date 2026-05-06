return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "*",
  opts = {
    keymap = {
      preset = "default",
      ["<C-y>"] = { "select_and_accept" },
    },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      menu = {
        draw = {
          treesitter = { "lsp" },
        },
      },
      list = {
        selection = { preselect = true, auto_insert = true },
      },
    },
    sources = {
      default = { "lsp", "path", "buffer" },
    },
  },
}
