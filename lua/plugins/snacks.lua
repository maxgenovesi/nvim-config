return {
  {
    "folke/snacks.nvim",
    opts = {
      -- Starting nvim with no file opens an empty buffer -- no dashboard,
      -- no explorer. Set this back to true to get LazyVim's dashboard.
      dashboard = { enabled = false },

      -- Don't highlight every other occurrence of the word under the cursor.
      --
      -- snacks' `words` module is what does this: on CursorHold it calls
      -- vim.lsp.buf.document_highlight() and paints the results with
      -- LspReferenceText / LspReferenceRead / LspReferenceWrite. LazyVim turns
      -- it on by default (lua/lazyvim/plugins/ui.lua), which is why it appears
      -- without anything here asking for it.
      --
      -- Note this also retires the ]] / [[ jumps between references, which is
      -- the other half of what the module provides. `grr` (LSP references in
      -- a picker) covers the same ground on demand.
      words = { enabled = false },
    },
  },
}
