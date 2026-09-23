local theme = require("config.theme")

return {
  -- The colorscheme carried over from the old kickstart config. Its setup is
  -- lackluster-specific and only runs if lackluster is the scheme in use; the
  -- cross-scheme tweaks live on the LazyVim spec below.
  {
    "slugbyte/lackluster.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      local lackluster = require("lackluster")
      local color = lackluster.color

      -- gray2 (#191919) matches the Lackluster Mint VSCode theme, which paints
      -- editor, sidebar, panel and terminal all at one tone -- a step up
      -- lackluster's grey ramp from the stock #101010 background.
      --
      -- gray3 (#2a2a2a) is the next step, and is what VSCode uses for its
      -- floating widgets, but it pushes the stock #3A3A3A comments down to
      -- ~1.26:1 contrast, so they'd need lightening alongside it.
      local bg = color.gray2

      lackluster.setup({
        disable_plugin = {
          -- lackluster defines all ~60 BufferLine* groups itself, and because
          -- the colorscheme is applied after bufferline's setup it overwrites
          -- whatever bufferline generated -- including the `highlights` table
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
    end,
  },

  -- Bluloco, ported from the VSCode theme of the same name. Needs lush at
  -- runtime: bluloco builds its highlights through it rather than shipping a
  -- static colors/ file.
  {
    "uloco/bluloco.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "rktjmp/lush.nvim" },
    init = function()
      require("bluloco").setup({
        style = "dark",
        transparent = false,
        italics = false,
        guicursor = false, -- lua/config/options.lua already sets guicursor
      })
    end,
  },

  {
    "LazyVim/LazyVim",
    -- LazyVim applies the colorscheme itself after plugins load, so name it
    -- here rather than calling vim.cmd.colorscheme.
    opts = {
      colorscheme = theme.scheme,
    },

    -- Registered from init (not config) so the autocmd exists before the
    -- colorscheme is first applied, and so it survives LazyVim applying the
    -- scheme late in startup.
    init = function()
      --- Re-paint the groups this config has an opinion about, in whichever
      --- scheme is now active. Reads every color from lua/config/theme.lua.
      ---
      --- A scheme with no palette there returns nil and is left completely
      --- untouched, so trying out a third colorscheme shows that scheme rather
      --- than a hybrid of it and the last one.
      local function apply_tweaks()
        local p = theme.palette()
        if not p then
          return
        end
        local set = function(group, opts)
          vim.api.nvim_set_hl(0, group, opts)
        end

        -- The current line's number. Under lackluster this is `luster`, the
        -- pale cyan it gives function names; under retrobox it is the scheme's
        -- own yellow, which is already what retrobox paints CursorLineNr.
        set("CursorLineNr", { fg = p.fg_active, bold = true })

        -- File-type icons in distinguishable colors.
        --
        -- mini.icons (which LazyVim uses, mocking nvim-web-devicons for
        -- neo-tree) ships no colors of its own -- it links its nine groups to
        -- Function, Constant and the Diagnostic* groups, which collapses them
        -- onto far fewer than nine distinct hues under any scheme. Setting them
        -- explicitly breaks the links. mini.icons defines its own with
        -- `default = true`, so it will never clobber these.
        for suffix, fg in pairs({
          Azure = p.icons.azure,
          Blue = p.icons.blue,
          Cyan = p.icons.cyan,
          Green = p.icons.green,
          Grey = p.icons.grey,
          Orange = p.icons.orange,
          Purple = p.icons.purple,
          Red = p.icons.red,
          Yellow = p.icons.yellow,
        }) do
          set("MiniIcons" .. suffix, { fg = fg })
        end

        -- Diagnostics, as a severity ramp: red > yellow > blue > green.
        --
        -- lackluster leaves Warn/Info/Hint at #444444 (1.35:1 against the
        -- background), so a warning was effectively invisible while its gutter
        -- sign was orange; retrobox defines no Diagnostic groups at all and
        -- falls back to Neovim's defaults. Both schemes set the base, Sign and
        -- VirtualText groups separately rather than linking them, so all three
        -- need setting per severity.
        --
        -- Warnings are yellow rather than orange so nothing in this ramp
        -- collides with the neo-tree git colors below.
        for severity, fg in pairs({
          Error = p.red,
          Warn = p.yellow,
          Info = p.blue,
          Hint = p.green,
        }) do
          for _, prefix in ipairs({ "Diagnostic", "DiagnosticSign", "DiagnosticVirtualText" }) do
            set(prefix .. severity, { fg = fg })
          end
          -- Underlines carry their color in `sp`, not `fg`.
          set("DiagnosticUnderline" .. severity, { undercurl = true, sp = fg })
        end

        -- Neo-tree git columns, following a file's journey into a commit:
        --   blue   = git has never seen it
        --   orange = tracked and edited, not yet staged
        --   green  = staged, safely in the index
        --   red    = destructive (deleted / conflicted)
        --   yellow = moved or renamed
        --
        -- Stock lackluster left Modified and Added at greys (#7a7a7a/#555555)
        -- while Untracked was a raw #ff8700 that isn't even in its palette --
        -- so "brand new file" shouted and "edited" was nearly silent.
        for group, hl in pairs({
          NeoTreeGitUntracked = { fg = p.blue },
          NeoTreeGitModified = { fg = p.orange },
          NeoTreeGitUnstaged = { fg = p.orange },
          NeoTreeGitAdded = { fg = p.green },
          NeoTreeGitStaged = { fg = p.green },
          NeoTreeGitRenamed = { fg = p.yellow },
          NeoTreeGitDeleted = { fg = p.red },
          NeoTreeGitConflict = { fg = p.red, bold = true },
          NeoTreeGitIgnored = { fg = p.subtle },
        }) do
          set(group, hl)
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("theme_tweaks", { clear = true }),
        callback = apply_tweaks,
      })
    end,
  },
}
