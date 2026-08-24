return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Everything here is LazyVim's clangd default except header insertion,
        -- which is the one preference carried over from the old config.
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never", -- was: iwyu
            "--completion-style=detailed",
            -- explicit boolean: Apple's clangd rejects the bare flag
            "--function-arg-placeholders=true",
            "--fallback-style=llvm",
          },
        },
      },
    },
  },
}
