-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Open the file explorer when nvim starts with no file argument.
-- Replaces LazyVim's dashboard, which is disabled in lua/plugins/snacks.lua.
--
-- This runs at file scope rather than from an autocmd on purpose. LazyVim
-- loads this file *on* the VeryLazy event, which is itself after VimEnter, so
-- an autocmd for either event would be registered too late to ever fire.
-- Running here means snacks' picker is already configured and ready.
local function opened_empty()
  -- `nvim file.txt` / `nvim some/dir` should open that instead
  if vim.fn.argc() > 0 then
    return false
  end
  local buf = vim.api.nvim_get_current_buf()
  -- a named or modified buffer means a real file or a restored session
  if vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].modified then
    return false
  end
  -- content in the scratch buffer means something was piped in via `nvim -`
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return #lines <= 1 and (lines[1] or "") == ""
end

if opened_empty() then
  vim.schedule(function()
    -- matches the old kickstart config's `Neotree show`: opens the sidebar
    -- but leaves the cursor in the main window
    require("neo-tree.command").execute({ action = "show", dir = LazyVim.root() })
  end)
end
