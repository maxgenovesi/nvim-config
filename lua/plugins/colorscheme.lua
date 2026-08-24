return {
  -- The colorscheme carried over from the old kickstart config.
  {
    "slugbyte/lackluster.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      local lackluster = require("lackluster")
      local color = lackluster.color

      -- Matches the Lackluster Mint VSCode theme, which paints editor,
      -- sidebar, panel and terminal all at #191919 -- i.e. color.gray2, one
      -- step up lackluster's grey ramp from the stock #101010 background.
      --
      -- gray3 (#2a2a2a) is the next step, and is what VSCode uses for its
      -- floating widgets, but it pushes the stock #3A3A3A comments down to
      -- ~1.26:1 contrast, so they'd need lightening alongside it.
      local bg = color.gray2

      lackluster.setup({
        disable_plugin = {
          -- lackluster defines all ~60 BufferLine* groups itself, and because
          -- the colorscheme is applied after bufferline's setup it overwrites
          -- whatever bufferline generated -- including our `highlights` table
          -- in lua/plugins/bufferline.lua. Standing lackluster down here lets
          -- bufferline's own config win, which is where the tabline is styled.
          bufferline = true,
        },
        tweak_syntax = {
          string = "default",
          string_escape = "default",
          comment = "default",
          builtin = "default",
          type = "default",
          keyword = "default",
          keyword_return = "default",
          keyword_exception = "default",
        },
        -- All four background surfaces share one tone: the buffer, telescope,
        -- the completion/wildmenu, and floats (lazy, mason, which-key).
        -- Neo-tree follows automatically, since NeoTreeNormal links to Normal.
        tweak_background = {
          normal = bg,
          telescope = bg,
          menu = bg,
          popup = bg,
        },
      })

      -- Re-apply custom highlights every time a colorscheme loads, so they
      -- survive LazyVim applying the scheme late in startup.
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("lackluster_tweaks", { clear = true }),
        callback = function()
          -- Current line number in color.luster (#deeeed) -- the pale cyan
          -- lackluster uses for function names (@function / @lsp.type.function).
          -- Other non-grey palette options: green #789978 (the mint accent),
          -- orange #ffaa88, yellow #abab77, blue #7788AA, red #D70000.
          vim.api.nvim_set_hl(0, "CursorLineNr", { fg = color.luster, bold = true })

          -- File-type icons in their own colors, not lackluster's.
          --
          -- mini.icons (which LazyVim uses, mocking nvim-web-devicons for
          -- neo-tree) ships no colors of its own -- it links its nine groups to
          -- colorscheme groups. Under lackluster, Blue/Cyan/Green/Orange/Yellow
          -- all resolve through the Diagnostic* groups to #444444, which is
          -- 1.35:1 against the #191919 background, and Azure/Purple land on
          -- plain greys. So nearly every icon reads as invisible grey.
          --
          -- These are the conventional nvim-web-devicons hues, set explicitly
          -- so the links can't drag them back to grey. mini.icons defines its
          -- own with `default = true`, so it will never clobber these.
          --
          -- Folder icons are untouched: neo-tree only runs the icon provider
          -- for file nodes, so directories keep NeoTreeDirectoryIcon's mint.
          for group, fg in pairs({
            MiniIconsAzure = "#6cb6eb",
            MiniIconsBlue = "#519aba",
            MiniIconsCyan = "#56b6c2",
            MiniIconsGreen = "#8dc149",
            MiniIconsGrey = color.gray7,
            MiniIconsOrange = "#e37933",
            MiniIconsPurple = "#a074c4",
            MiniIconsRed = "#cc3e44",
            MiniIconsYellow = "#cbcb41",
          }) do
            vim.api.nvim_set_hl(0, group, { fg = fg })
          end

          -- Diagnostics. Lackluster leaves Warn/Info/Hint at #444444 -- the
          -- same 1.35:1 grey the icon block above works around -- so a warning
          -- was effectively invisible while its gutter sign was orange. It
          -- also sets the base/Sign/VirtualText groups separately instead of
          -- linking them, so all three need setting per severity.
          --
          -- Severity now reads as a ramp: red > yellow > blue > green.
          -- Warnings are yellow rather than orange so that nothing in the
          -- diagnostic ramp collides with neo-tree's git colors below.
          for severity, fg in pairs({
            Error = color.red,
            Warn = color.yellow,
            Info = color.blue,
            Hint = color.green,
          }) do
            for _, prefix in ipairs({ "Diagnostic", "DiagnosticSign", "DiagnosticVirtualText" }) do
              vim.api.nvim_set_hl(0, prefix .. severity, { fg = fg })
            end
            -- Underlines carry their color in `sp`, not `fg`.
            vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. severity, { undercurl = true, sp = fg })
          end

          -- Neo-tree git columns. Stock lackluster left Modified and Added at
          -- greys (#7a7a7a / #555555) while Untracked was a raw #ff8700 that
          -- isn't even in the palette -- so "brand new file" shouted and
          -- "edited" was nearly silent, which is backwards.
          --
          -- The rule now follows a file's journey into a commit:
          --   blue   = git has never seen it
          --   orange = tracked and edited, not yet staged
          --   green  = staged, safely in the index
          --   red    = destructive (deleted / conflicted)
          --   yellow = moved or renamed
          for group, hl in pairs({
            NeoTreeGitUntracked = { fg = color.blue },
            NeoTreeGitModified = { fg = color.orange },
            NeoTreeGitUnstaged = { fg = color.orange },
            NeoTreeGitAdded = { fg = color.green },
            NeoTreeGitStaged = { fg = color.green },
            NeoTreeGitRenamed = { fg = color.yellow },
            NeoTreeGitDeleted = { fg = color.red },
            NeoTreeGitConflict = { fg = color.red, bold = true },
            NeoTreeGitIgnored = { fg = color.gray4 },
          }) do
            vim.api.nvim_set_hl(0, group, hl)
          end
        end,
      })
    end,
  },

  -- Tell LazyVim to actually use it. LazyVim applies the colorscheme itself
  -- after plugins load, so set it here rather than calling vim.cmd.colorscheme.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "lackluster-mint",
    },
  },
}
