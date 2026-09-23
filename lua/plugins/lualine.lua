return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local theme = require("config.theme")

      opts.options = opts.options or {}
      opts.options.theme = theme.lualine_theme()

      -- lualine picks its theme once, at setup, so a colorscheme switch would
      -- otherwise leave the statusline wearing the previous scheme's palette.
      -- Re-run setup with the new theme name instead.
      --
      -- Scheduled because this fires inside lualine's own ColorScheme handler;
      -- deferring to the next tick keeps setup() from re-entering it. Guarded
      -- on package.loaded so the autocmd can't force lualine to load early
      -- during startup.
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("lualine_theme", { clear = true }),
        callback = vim.schedule_wrap(function()
          if not package.loaded["lualine"] then
            return
          end
          local name = theme.lualine_theme()
          if opts.options.theme ~= name then
            opts.options.theme = name
            require("lualine").setup(opts)
          end
        end),
      })

      return opts
    end,
  },
}
