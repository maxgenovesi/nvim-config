return {
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      local color = require("lackluster").color

      -- Mirrors the Lackluster Mint VSCode theme, whose tab colors are drawn
      -- from this same palette. The tab bar sits at the buffer's own tone so
      -- there's no seam, and only the tabs themselves lift out of it:
      --
      --   gray2 #191919  bar + inactive tabs   == editorGroupHeader.tabsBackground
      --   gray3 #2a2a2a  the 1px tab border    == tab.border
      --   gray4 #444444  visible-but-unfocused == tab.unfocusedActiveBackground
      --   gray5 #555555  the active tab        == tab.activeBackground
      local bg_bar = color.gray2 -- #191919, identical to the buffer below
      local bg_visible = color.gray4 -- #444444
      local bg_active = color.gray5 -- #555555
      local border = color.gray3 -- #2a2a2a

      -- tab.inactiveForeground / unfocusedActiveForeground / activeForeground
      local fg_inactive = color.gray6 -- #7a7a7a
      local fg_visible = color.gray8 -- #cccccc
      local fg_active = color.luster -- #deeeed

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
      -- lackluster's mint fg and no bg -- so the header block falls back to a
      -- tone that doesn't match the bar. Point it at our own group instead,
      -- styled after VSCode's titleBar.activeForeground (#aaaaaa) on the bar.
      for _, offset in ipairs(opts.options.offsets or {}) do
        if offset.filetype == "neo-tree" then
          offset.highlight = "NeoTreeTabHeader"
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("bufferline_offset_header", { clear = true }),
        callback = function()
          vim.api.nvim_set_hl(0, "NeoTreeTabHeader", { fg = color.gray7, bg = bg_bar })
        end,
      })
      vim.api.nvim_set_hl(0, "NeoTreeTabHeader", { fg = color.gray7, bg = bg_bar })

      -- Set these through bufferline's own `highlights` table rather than
      -- nvim_set_hl: bufferline regenerates its groups on every ColorScheme
      -- event, which would clobber external overrides.
      opts.highlights = vim.tbl_deep_extend("force", opts.highlights or {}, {
        fill = { bg = bg_bar },

        -- inactive / visible / active tab bodies
        background = { fg = fg_inactive, bg = bg_bar },
        buffer_visible = { fg = fg_visible, bg = bg_visible },
        buffer_selected = { fg = fg_active, bg = bg_active, bold = true, italic = false },

        -- VSCode draws a 1px tab.border between tabs; bufferline's separator
        -- fg is that line, its bg is the tab the separator belongs to.
        separator = { fg = border, bg = bg_bar },
        separator_visible = { fg = border, bg = bg_visible },
        separator_selected = { fg = border, bg = bg_active },
        offset_separator = { fg = border, bg = bg_bar },

        -- no top/side indicator bar in the VSCode theme, so flatten it away
        indicator_visible = { fg = bg_visible, bg = bg_visible },
        indicator_selected = { fg = bg_active, bg = bg_active },
        trunc_marker = { fg = fg_inactive, bg = bg_bar },

        -- modified dot
        modified = { fg = color.orange, bg = bg_bar },
        modified_visible = { fg = color.orange, bg = bg_visible },
        modified_selected = { fg = color.orange, bg = bg_active },

        -- close buttons
        close_button = { fg = fg_inactive, bg = bg_bar },
        close_button_visible = { fg = fg_visible, bg = bg_visible },
        close_button_selected = { fg = fg_active, bg = bg_active },

        -- duplicate filenames get the directory prefix
        duplicate = { fg = fg_inactive, bg = bg_bar, italic = true },
        duplicate_visible = { fg = fg_visible, bg = bg_visible, italic = true },
        duplicate_selected = { fg = fg_active, bg = bg_active, italic = true },

        -- Diagnostics recolor the filename itself, since the icon is gone.
        -- color.red (#d70000) is exactly what lackluster gives DiagnosticError,
        -- so an erroring tab matches neo-tree's error color.
        error = { fg = color.red, bg = bg_bar },
        error_visible = { fg = color.red, bg = bg_visible },
        error_selected = { fg = color.red, bg = bg_active, bold = true, italic = false },
        warning = { fg = color.yellow, bg = bg_bar },
        warning_visible = { fg = color.yellow, bg = bg_visible },
        warning_selected = { fg = color.yellow, bg = bg_active, bold = true, italic = false },
        info = { fg = color.blue, bg = bg_bar },
        info_visible = { fg = color.blue, bg = bg_visible },
        info_selected = { fg = color.blue, bg = bg_active, bold = true, italic = false },
        hint = { fg = color.lack, bg = bg_bar },
        hint_visible = { fg = color.lack, bg = bg_visible },
        hint_selected = { fg = color.lack, bg = bg_active, bold = true, italic = false },

        -- The trailing diagnostic count. Unused while diagnostics_indicator
        -- returns "", but kept correct so restoring an indicator still fits.
        diagnostic = { fg = fg_inactive, bg = bg_bar },
        diagnostic_visible = { fg = fg_visible, bg = bg_visible },
        diagnostic_selected = { fg = fg_active, bg = bg_active, bold = true, italic = false },
      })

      return opts
    end,
  },
}
