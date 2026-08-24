# nvim-config

My personal [LazyVim](https://github.com/LazyVim/LazyVim) setup.

The main thing here is a [lackluster.nvim](https://github.com/slugbyte/lackluster.nvim)
theme, tuned to match the Lackluster Mint VSCode theme: every surface (buffer,
telescope, floats, neo-tree) sits at one tone, with the tabline and diagnostics
recolored so nothing important renders as invisible grey.

## Layout

```
init.lua              bootstraps lua/config/lazy.lua
lua/config/           LazyVim's options, keymaps, autocmds
lua/plugins/          per-plugin overrides
  colorscheme.lua     lackluster-mint + icon/diagnostic/git-column fixes
  bufferline.lua      tabline styled after the VSCode theme's tab colors
```

## Install

```sh
git clone git@github.com:maxgenovesi/nvim-config.git ~/.config/nvim
nvim
```

Plugins bootstrap themselves on first launch. `lazy-lock.json` is committed, so
you get the exact versions this config was last known to work with.
