return {
  "rmagatti/auto-session",
  event = "VimEnter",
  opts = {
    suppressed_dirs = { "~/", "~/Downloads", "/tmp" },
    session_lens = {
      load_on_setup = true,
    },
  },
}
