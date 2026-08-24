return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- lualine's "auto" theme looks for a theme file matching vim.g.colors_name,
      -- i.e. "lackluster-mint" — which does not exist. lackluster ships its
      -- statusline theme as plain "lackluster", so point at it explicitly;
      -- otherwise lualine invents its own palette that clashes with the scheme.
      opts.options = opts.options or {}
      opts.options.theme = "lackluster"
      return opts
    end,
  },
}
