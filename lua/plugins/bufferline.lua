return {
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      local theme = require("config.theme")

      opts.options = opts.options or {}
      opts.options.always_show_bufferline = false

      -- LazyVim's default indicator appends the diagnostic icon + count to the
      -- tab, which drags in the *_diagnostic highlight groups and their own
      -- backgrounds -- a mismatched patch against our flat tab bar.
      --
      -- Returning an empty string drops the icon without losing the coloring:
      -- bufferline's diagnostics component pushes the error/warning highlight
      -- onto the filename via `attr.extends` (diagnostics.lua), and empty
      -- segments still survive `filter_invalid` (ui.lua), which only drops
      -- nils. So the tab shows a red filename and nothing else.
      opts.options.diagnostics_indicator = function()
        return ""
      end

      -- LazyVim pins the neo-tree offset header to "Directory", which carries
      -- a foreground but no background -- so the header block falls back to a
      -- tone that doesn't match the bar. Point it at our own group instead,
      -- styled after VSCode's titleBar.activeForeground on the bar.
      for _, offset in ipairs(opts.options.offsets or {}) do
        if offset.filetype == "neo-tree" then
          offset.highlight = "NeoTreeTabHeader"
        end
      end

      local function set_tab_header()
        local p = theme.palette()
        if p then
          vim.api.nvim_set_hl(0, "NeoTreeTabHeader", { fg = p.fg_dim, bg = p.bg })
        end
      end
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("bufferline_offset_header", { clear = true }),
        callback = set_tab_header,
      })
      set_tab_header()

      -- A *function* rather than a table, because bufferline re-runs it on
      -- every ColorScheme event (config.update_highlights -> Config:resolve,
      -- which calls `user.highlights(defaults)` when it is callable). That is
      -- what re-tints the tab bar on a scheme switch. A static table would be
      -- resolved once at setup and leave the tabs wearing the old palette.
      --
      -- Note the function has to return the *whole* table: when highlights is
      -- callable, resolve() uses its return value in place of the merged
      -- defaults rather than merging on top of them.
      local lazyvim_highlights = opts.highlights

      opts.highlights = function(defaults)
        local hl = vim.tbl_deep_extend("force", defaults.highlights or {}, lazyvim_highlights or {})

        local p = theme.palette()
        if not p then
          return hl
        end

        -- The tab bar sits at the buffer's own tone so there is no seam, and
        -- only the tabs themselves lift out of it. Under lackluster this
        -- mirrors the Lackluster Mint VSCode theme's tab colors; under
        -- retrobox it is the same shape walked up gruvbox's bg0..bg3 ramp.
        --
        --   bg          bar + inactive tabs   == editorGroupHeader.tabsBackground
        --   bg_border   the 1px tab border    == tab.border
        --   bg_visible  visible-but-unfocused == tab.unfocusedActiveBackground
        --   bg_active   the active tab        == tab.activeBackground
        local bar, visible, active, border = p.bg, p.bg_visible, p.bg_active, p.bg_border

        -- tab.inactiveForeground / unfocusedActiveForeground / activeForeground
        local fg_inactive, fg_visible, fg_active = p.fg_inactive, p.fg_visible, p.fg_active

        local tabs = {
          fill = { bg = bar },

          -- inactive / visible / active tab bodies
          background = { fg = fg_inactive, bg = bar },
          buffer_visible = { fg = fg_visible, bg = visible },
          buffer_selected = { fg = fg_active, bg = active, bold = true, italic = false },

          -- VSCode draws a 1px tab.border between tabs; bufferline's separator
          -- fg is that line, its bg is the tab the separator belongs to.
          separator = { fg = border, bg = bar },
          separator_visible = { fg = border, bg = visible },
          separator_selected = { fg = border, bg = active },
          offset_separator = { fg = border, bg = bar },

          -- no top/side indicator bar in the VSCode theme, so flatten it away
          indicator_visible = { fg = visible, bg = visible },
          indicator_selected = { fg = active, bg = active },
          trunc_marker = { fg = fg_inactive, bg = bar },

          -- modified dot
          modified = { fg = p.orange, bg = bar },
          modified_visible = { fg = p.orange, bg = visible },
          modified_selected = { fg = p.orange, bg = active },

          -- close buttons
          close_button = { fg = fg_inactive, bg = bar },
          close_button_visible = { fg = fg_visible, bg = visible },
          close_button_selected = { fg = fg_active, bg = active },

          -- duplicate filenames get the directory prefix
          duplicate = { fg = fg_inactive, bg = bar, italic = true },
          duplicate_visible = { fg = fg_visible, bg = visible, italic = true },
          duplicate_selected = { fg = fg_active, bg = active, italic = true },

          -- Diagnostics recolor the filename itself, since the icon is gone.
          -- These are the same four hues the Diagnostic* groups get in
          -- lua/plugins/colorscheme.lua, so an erroring tab matches its
          -- neo-tree entry and its gutter sign.
          error = { fg = p.red, bg = bar },
          error_visible = { fg = p.red, bg = visible },
          error_selected = { fg = p.red, bg = active, bold = true, italic = false },
          warning = { fg = p.yellow, bg = bar },
          warning_visible = { fg = p.yellow, bg = visible },
          warning_selected = { fg = p.yellow, bg = active, bold = true, italic = false },
          info = { fg = p.blue, bg = bar },
          info_visible = { fg = p.blue, bg = visible },
          info_selected = { fg = p.blue, bg = active, bold = true, italic = false },
          hint = { fg = p.green, bg = bar },
          hint_visible = { fg = p.green, bg = visible },
          hint_selected = { fg = p.green, bg = active, bold = true, italic = false },

          -- The trailing diagnostic count. Unused while diagnostics_indicator
          -- returns "", but kept correct so restoring an indicator still fits.
          diagnostic = { fg = fg_inactive, bg = bar },
          diagnostic_visible = { fg = fg_visible, bg = visible },
          diagnostic_selected = { fg = fg_active, bg = active, bold = true, italic = false },
        }

        -- Mark ours non-default, or a scheme switch silently does nothing.
        --
        -- bufferline stamps `default = true` on every group it sets (that is
        -- what options.themable means -- it lets a colorscheme style the tabs),
        -- and nvim_set_hl treats a default highlight as "define this only if it
        -- does not already exist". So the groups created under the *first*
        -- colorscheme of the session stick, and re-setting them on ColorScheme
        -- is a no-op.
        --
        -- Only our own entries are flagged: for a scheme with no palette we
        -- return `hl` untouched above, leaving themable intact so that scheme
        -- can style bufferline itself, the way tokyonight does.
        for _, spec in pairs(tabs) do
          spec.default = false
        end

        return vim.tbl_deep_extend("force", hl, tabs)
      end

      return opts
    end,
  },
}
