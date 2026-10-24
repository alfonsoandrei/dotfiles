return {
  "rmagatti/auto-session",
  event = "VimEnter",
  -- The scratch window opens its own notes, so a restored session would replace them.
  cond = vim.env.SCRATCH_ACTION == nil,
  opts = {
    suppressed_dirs = { "~/", "~/Downloads", "/tmp" },
    session_lens = {
      load_on_setup = true,
    },
  },
}
