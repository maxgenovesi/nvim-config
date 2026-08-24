return {
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        -- Put the command line back on the bottom row instead of noice's
        -- floating popup in the middle of the screen. Everything else noice
        -- does (LSP hover/signature styling, message routing, <leader>sn
        -- history) is untouched.
        view = "cmdline",
      },
    },
  },
}
