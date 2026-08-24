return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      default_component_configs = {
        git_status = {
          -- Neo-tree renders at most two glyphs per file, and they answer two
          -- different questions. Stock (and LazyVim's) symbols are nerd-font
          -- pictographs that are hard to tell apart at a glance, so use the
          -- letters `git status --short` already prints -- the tree then
          -- teaches the same vocabulary as the command line.
          --
          --   WHERE it lives          WHAT changed
          --   ? untracked             A added
          --   ○ not staged            M modified
          --   ● staged                D deleted
          --   ! conflicted            R renamed
          --   · ignored
          --
          -- They combine, change letter first: `M ○` is "modified, not
          -- staged yet" and `A ●` is "new file, staged". Untracked and
          -- ignored files short-circuit to a single glyph, since there is no
          -- index entry left to describe.
          symbols = {
            -- Change type
            added = "A",
            modified = "M",
            deleted = "D",
            renamed = "R",
            -- Status type
            untracked = "?",
            ignored = "·",
            unstaged = "○",
            staged = "●",
            conflict = "!",
          },
        },
      },
    },
  },
}
