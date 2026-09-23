# nvim-config

My personal [LazyVim](https://github.com/LazyVim/LazyVim) setup.

The main thing here is theming. Three schemes are set up, and the tweaks this
config makes -- the tabline, diagnostics, git columns and file icons, none of
which any scheme gets right on its own -- follow whichever one is active:

- **lackluster-mint**, tuned to match the Lackluster Mint VSCode theme: every
  surface (buffer, telescope, floats, neo-tree) sits at one tone.
- **retrobox**, Neovim's builtin gruvbox port.
- **bluloco** (dark), ported from the VSCode theme of the same name.

Each gets the same tweaks walked up its own palette. Any other colorscheme --
bluloco's light variant included -- is left entirely alone, rather than
inheriting half of one of these.

## Switching themes

```sh
# nvim: change M.scheme in lua/config/theme.lua, then restart
# tmux:
tmux-theme bluloco         # or: prefix + T to cycle
tmux-theme                 # print the active theme and the available ones
```

The two are switched separately; nvim does not drive tmux.

To add a scheme: add its plugin to `lua/plugins/colorscheme.lua`, a palette to
`lua/config/theme.lua` (every key the others define), a `themes/<name>.conf` to
tmux, and one `if-shell` line to `tmux.conf`.

## Layout

```
init.lua              bootstraps lua/config/lazy.lua
lua/config/           LazyVim's options, keymaps, autocmds
  theme.lua           the theme switch + one semantic palette per scheme
lua/plugins/          per-plugin overrides
  colorscheme.lua     scheme setup + icon/diagnostic/git-column fixes
  bufferline.lua      tabline styled after the VSCode theme's tab colors
  lualine.lua         picks the statusline theme matching the scheme
```

Every color lives in `lua/config/theme.lua` as a named role (`bg_active`,
`fg_inactive`, `red`); nothing else hardcodes a hex. The tmux side mirrors those
palettes by hand in `~/.config/tmux/themes/`, since tmux cannot read Lua.

## Install

```sh
git clone git@github.com:maxgenovesi/nvim-config.git ~/.config/nvim
nvim
```

Plugins bootstrap themselves on first launch. `lazy-lock.json` is committed, so
you get the exact versions this config was last known to work with.
