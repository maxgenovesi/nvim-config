return {
  {
    "folke/snacks.nvim",
    opts = {
      -- Starting nvim with no file opens the explorer instead of the
      -- dashboard. See the VimEnter autocmd in lua/config/autocmds.lua.
      dashboard = { enabled = false },
    },
  },
}
