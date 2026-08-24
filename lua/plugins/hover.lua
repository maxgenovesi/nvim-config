return {
  {
    "lewis6991/hover.nvim",
    event = "VeryLazy",
    -- hover.nvim's entry point is config(), not setup(), so lazy.nvim can't
    -- forward opts automatically.
    config = function(_, opts)
      require("hover").config(opts)

      -- Cycle sources inside an open hover window. When no window is open,
      -- replay the builtin <C-n>/<C-p> (down/up a line).
      -- Not an expr mapping: expr runs under textlock, and switch() opens a
      -- window, which errors with E565.
      local function switch(direction, fallback)
        return function()
          local win = vim.b.hover_preview
          if win and vim.api.nvim_win_is_valid(win) then
            require("hover").switch(direction)
          else
            vim.api.nvim_feedkeys(vim.keycode(fallback), "n", false)
          end
        end
      end

      local map = vim.keymap.set
      map("n", "<C-n>", switch("next", "<C-n>"), { desc = "Hover: Next Source" })
      map("n", "<C-p>", switch("previous", "<C-p>"), { desc = "Hover: Prev Source" })

      -- Mouse hover is off. To re-enable, uncomment the two statements below.
      -- Neovim only emits <MouseMove> when 'mousemoveevent' is set ('mouse' is
      -- already "a" from LazyVim). Map it here rather than in the lazy `keys`
      -- table so no lazy-load stub sits on a high-frequency event. Normal mode
      -- only: in insert mode it fires while typing and fights blink.cmp.
      -- vim.o.mousemoveevent = true
      -- map("n", "<MouseMove>", function()
      --   require("hover").mouse()
      -- end, { desc = "Hover: Mouse" })
    end,
    opts = {
      -- Sources, tried in priority order. The first with a result is shown;
      -- <C-n>/<C-p> (or K again) cycle to the rest without closing the window.
      --   fold_preview 1003 > diagnostic 1001 > lsp 1000 > man 150
      --   > dictionary 100 > highlight (none)
      -- so landing on an error shows the error first, and <C-n> gets LSP docs.
      providers = {
        "hover.providers.diagnostic",
        "hover.providers.lsp",
        "hover.providers.fold_preview", -- contents of a closed fold
        "hover.providers.highlight", -- highlight groups under cursor (vim.inspect_pos)
        "hover.providers.man",
        "hover.providers.dictionary",
      },

      -- The view. preview_opts reaches hover's float builder, which honours
      -- border / max_width / max_height / focusable / relative / zindex.
      preview_opts = {
        border = "rounded",
        max_width = 90,
        max_height = 25,
      },

      -- false = keep the float. true would dump contents into a :preview-window
      -- instead. Note: a second K cycles to the next source (same as <C-n>);
      -- use <leader>k to step into the float and scroll it.
      preview_window = false,

      -- Show the source name ("LSP", "Diagnostic", ...) in the border.
      title = true,

      -- Sources used for mouse hover only (keyboard K uses `providers` above).
      -- Unused while the <MouseMove> map above is commented out, but kept so
      -- re-enabling is a two-line change. Diagnostics included so resting the
      -- pointer on a squiggle shows the error; mouse_delay is the dwell in ms.
      mouse_providers = {
        "hover.providers.diagnostic",
        "hover.providers.lsp",
      },
      mouse_delay = 500,
    },
    -- stylua: ignore
    keys = {
      { "<leader>k", function() require("hover").enter() end, desc = "Hover (focus window)" },
      { "<leader>ck", function() require("hover").select() end, desc = "Hover (pick source)" },
    },
  },

  {
    -- LazyVim sets K as a buffer-local LSP keymap on LspAttach, which would
    -- shadow any global mapping. Appending an entry with the same lhs here
    -- overrides it (lazy resolves keys by lhs, last one wins).
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      local all = opts.servers["*"] or {}
      all.keys = all.keys or {}
      table.insert(all.keys, {
        "K",
        function()
          require("hover").open()
        end,
        desc = "Hover",
      })
      opts.servers["*"] = all
    end,
  },
}
