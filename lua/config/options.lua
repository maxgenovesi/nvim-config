-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use telescope + neo-tree instead of LazyVim's snacks picker/explorer, both
-- for the familiar kickstart feel and because lackluster styles them natively.
-- LazyVim reads these to pick which extras to import, so do NOT also import
-- lazyvim.plugins.extras.editor.{telescope,neo-tree} by hand -- that would
-- register two pickers and double-map <leader>e.
vim.g.lazyvim_picker = "telescope"
vim.g.lazyvim_explorer = "neo-tree"

local opt = vim.opt

-- Relative line numbers, for jumping by count.
opt.relativenumber = true

-- Highlight the current line's *number* only -- no background band across the
-- line itself. `cursorline` has to be on for CursorLineNr to apply at all;
-- with cursorlineopt="number" the line stays unhighlighted, which is the look
-- `cursorline = false` was getting before (but that also left the current line
-- number rendering as plain dim LineNr).
opt.cursorline = true
opt.cursorlineopt = "number"

-- Block cursor in normal/visual/command, thin vertical bar in insert.
-- (`ver25` is a bar 25% of a cell wide; `hor20` is the replace-mode underline.)
-- Set explicitly rather than left to Neovim's default so the intent is clear:
-- an empty guicursor hands the cursor to the terminal and it stops changing
-- shape between modes entirely.
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor"

-- Hide the `~` filler on lines past the end of the buffer.
opt.fillchars:append({ eob = " " })

-- LazyVim turns `list` on but never sets `listchars`, so Neovim's default
-- "tab:> " draws a `>` at every tab stop -- visible even with indent guides
-- off. Blank out the tab marker; keep the genuinely useful trail/nbsp ones.
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
